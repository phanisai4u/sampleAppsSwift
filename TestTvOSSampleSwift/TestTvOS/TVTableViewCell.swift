//
//  TVTableViewCell.swift
//  TestTvOS
//
//  Created by Phani on 11/24/15.
//  Copyright © 2015 Phani. All rights reserved.
//

import UIKit

class TVTableViewCell: UITableViewCell {

    @IBOutlet weak var Labeltest: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
