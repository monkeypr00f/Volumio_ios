//
//  PluginTableViewCell.swift
//  Volumio
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

        pluginStatus.layer.cornerRadius = 8
    }

}
