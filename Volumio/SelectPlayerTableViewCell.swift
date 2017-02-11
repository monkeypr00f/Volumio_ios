//
//  SelectPlayerTableViewCell.swift
//  Volumio
//
//  Created by Federico Sintucci on 18/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class SelectPlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var playerBorder: UIView!
    @IBOutlet weak var playerName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        playerBorder.layer.borderWidth = 1
        playerBorder.layer.borderColor = UIColor.selectPlayerCellBorder.cgColor
        playerBorder.layer.cornerRadius = 5
    }

}
