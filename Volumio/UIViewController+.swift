//
//  UIViewController+.swift
//  Volumio
//
//  Created by Michael Baumgärtner on 01.02.17.
//  Copyright © 2017 Federico Sintucci. All rights reserved.
//

import UIKit

extension UIViewController {

    class func instantiate(
        fromStoryboard storyboardName: String,
        withIdentifier identifier: String
    ) -> Self {
        return instantiateFromStoryboardHelper(storyboardName, identifier)
    }

    private class func instantiateFromStoryboardHelper<T>(
        _ storyboardName: String, _ storyboardId: String
    ) -> T {
        let anyStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        let anyController = anyStoryboard.instantiateViewController(withIdentifier: storyboardId)

        guard let controller = anyController as? T
            else { fatalError() }

        return controller
    }
}
