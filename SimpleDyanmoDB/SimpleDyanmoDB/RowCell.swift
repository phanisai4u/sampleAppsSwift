//
//  RowCell.swift
//  SimpleDyanmoDB
//
//  Created by Phani on 12/2/15.
//  Copyright © 2015 Phani. All rights reserved.
//

import UIKit

class RowCell: UITableViewCell {

    @IBOutlet var artist: UILabel!
    @IBOutlet var SongTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
