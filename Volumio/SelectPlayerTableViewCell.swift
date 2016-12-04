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
        // Initialization code
        
        playerBorder.layer.borderWidth = 1
        playerBorder.layer.borderColor = UIColor(red: 162.0/255.0, green: 155.0/255.0, blue: 154.0/255.0, alpha: 1).cgColor
        playerBorder.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
