//
//  DynamoDBMapper.swift
//  SimpleDyanmoDB
//
//  Created by Phani on 12/2/15.
//  Copyright © 2015 Phani. All rights reserved.
//

import Foundation
class DDBDynamoDBManger : NSObject {
    class func describeTable() -> AWSTask {
        let dynamoDB = AWSDynamoDB.defaultDynamoDB()
        
        // See if the test table exists.
        let describeTableInput = AWSDynamoDBDescribeTableInput()
        describeTableInput.tableName = AWSSampleDynamoDBTableName
        return dynamoDB.describeTable(describeTableInput)
    }
    
    class func createTable() -> AWSTask {
        let dynamoDB = AWSDynamoDB.defaultDynamoDB()
        
        //Create the test table
        let hashKeyAttributeDefinition = AWSDynamoDBAttributeDefinition()
        hashKeyAttributeDefinition.attributeName = "Artist"
        hashKeyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeType.S
        
        let hashKeySchemaElement = AWSDynamoDBKeySchemaElement()
        hashKeySchemaElement.attributeName = "Artist"
        hashKeySchemaElement.keyType = AWSDynamoDBKeyType.Hash
        
        let rangeKeyAttributeDefinition = AWSDynamoDBAttributeDefinition()
        rangeKeyAttributeDefinition.attributeName = "SongTitle"
        rangeKeyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeType.S
        
               let createTableInput = AWSDynamoDBCreateTableInput()
        createTableInput.tableName = AWSSampleDynamoDBTableName;
        createTableInput.attributeDefinitions = [hashKeyAttributeDefinition, rangeKeyAttributeDefinition]
        // createTableInput.keySchema = [hashKeySchemaElement, rangeKeySchemaElement]
        // createTableInput.provisionedThroughput = provisionedThroughput
        //  createTableInput.globalSecondaryIndexes = gsiArray as [AnyObject]
        
        return dynamoDB.createTable(createTableInput).continueWithSuccessBlock({ (var task:AWSTask!) -> AnyObject! in
            if ((task.result) != nil) {
                // Wait for up to 4 minutes until the table becomes ACTIVE.
                
                let describeTableInput = AWSDynamoDBDescribeTableInput()
                describeTableInput.tableName = AWSSampleDynamoDBTableName;
                task = dynamoDB.describeTable(describeTableInput)
                
                for var i = 0; i < 16; i++ {
                    task = task.continueWithSuccessBlock({ (task:AWSTask!) -> AnyObject! in
                        let describeTableOutput:AWSDynamoDBDescribeTableOutput = task.result as! AWSDynamoDBDescribeTableOutput
                        let tableStatus = describeTableOutput.table.tableStatus
                        if tableStatus == AWSDynamoDBTableStatus.Active {
                            return task
                        }
                        
                        sleep(15)
                        return dynamoDB .describeTable(describeTableInput)
                    })
                }
            }
            
            return task
        })
        
    }
}

class DDBTableRow :AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    
    var Artist:String?
    var SongTitle:String?
    
    
    class func dynamoDBTableName() -> String! {
        return AWSSampleDynamoDBTableName
    }
    
    class func hashKeyAttribute() -> String! {
        return "Artist"
    }
    
    class func rangeKeyAttribute() -> String! {
        return "SongTitle"
    }
    
    class func ignoreAttributes() -> Array<AnyObject>! {
        return ["internalName","internalState"]
    }
    
    //MARK: NSObjectProtocol hack
    override func isEqual(object: AnyObject?) -> Bool {
        return super.isEqual(object)
    }
    
    override func `self`() -> Self {
        return self
    }
}

