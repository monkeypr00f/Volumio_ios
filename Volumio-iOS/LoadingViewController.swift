//
//  LoadingViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 17/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var switchOnView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        SocketIOManager.sharedInstance.closeConnection()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("connected"), object: nil, queue: nil, using: { notification in
            if let top = UIApplication.shared.keyWindow?.rootViewController {
                top.dismiss(animated: true, completion: nil)
            }
        })
        
        timer = Timer(timeInterval: 5.0, target: self, selector: #selector(resetButton), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connectButton(_ sender: UIButton) {
        SocketIOManager.sharedInstance.reConnect()
        reloadButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func resetButton() {
        reloadButton.isHidden = false
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
