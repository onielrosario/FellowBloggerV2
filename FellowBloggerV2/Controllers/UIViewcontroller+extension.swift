//
//  UIViewcontroller+extension.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/18/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit

extension UIViewController {
    public func showLoginView() {
        if let _ = storyboard?.instantiateViewController(withIdentifier: "MainTab") as? MainTabController {
            dismiss(animated: true)
            let loginViewStoryboard = UIStoryboard(name: "Login", bundle: nil)
            if let loginViewController = loginViewStoryboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController {
                (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = loginViewController
            }
        } else {
            dismiss(animated: true)
        }
    }
}
