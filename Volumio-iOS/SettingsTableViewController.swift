//
//  SettingsTableViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 09/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 0: shutdownAlert()
            default: return
        }
    }
    
    func shutdownAlert() {
        let alert = UIAlertController(title: "Volumio", message: "", preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "Shutdown", style: .default, handler: { (action) in
                SocketIOManager.sharedInstance.doAction(action: "shutdown")
            })
        )
        alert.addAction(
            UIAlertAction(title: "Reboot", style: .default, handler: { (action) in
                SocketIOManager.sharedInstance.doAction(action: "reboot")
            })
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
