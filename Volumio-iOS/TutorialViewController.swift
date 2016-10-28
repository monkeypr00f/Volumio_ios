//
//  TutorialViewController.swift
//  Volumio-iOS
//
//  Created by Federico Sintucci on 27/10/16.
//  Copyright © 2016 Federico Sintucci. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var swipeLeftView: SwipeLeft!
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: "hideSwipeTutorial")
                
        timer = Timer(timeInterval: 2.5, target: self, selector: #selector(startAnimation), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startAnimation() {
        swipeLeftView.addToLeftAnimation()
    }
    
    @IBAction func closeTutorial(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
