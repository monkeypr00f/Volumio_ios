//
//  PluginTableViewCell.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 17/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class PluginTableViewCell: UITableViewCell {

    @IBOutlet weak var pluginName: UILabel!
    @IBOutlet weak var pluginStatus: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
