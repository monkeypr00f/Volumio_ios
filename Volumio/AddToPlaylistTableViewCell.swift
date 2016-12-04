//
//  AddToPlaylistTableViewCell.swift
//  Volumio
//
//  Created by Federico Sintucci on 08/11/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class AddToPlaylistTableViewCell: UITableViewCell {

    @IBOutlet weak var playlistBorder: UIView!
    @IBOutlet weak var playlistName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        playlistBorder.layer.borderWidth = 0.5
        playlistBorder.layer.borderColor = UIColor(red: 191.0/255.0, green: 184.0/255.0, blue: 185.0/255.0, alpha: 1).cgColor
        playlistBorder.layer.cornerRadius = 5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
