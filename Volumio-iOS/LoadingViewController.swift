//
//  LoadingViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 11/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var powerOnAnimationView: PowerOnSwitchView!
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        timer = Timer(timeInterval: 5.0, target: self, selector: #selector(startAnimation), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("connected"), object: nil, queue: nil, using: { notification in
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarViewController
            self.present(controller, animated: true, completion: nil)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startAnimation() {
        powerOnAnimationView.addSwitchOnAnimation()
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
