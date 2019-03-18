//
//  AddBloggViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/17/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit

class AddBloggViewController: UIViewController {
    @IBOutlet weak var blogDescription: UITextView!
    @IBOutlet weak var newBlogImage: UIImageView!
    @IBOutlet weak var newBlogImageIcon: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
      blogDescription.clipsToBounds = true
    blogDescription.layer.cornerRadius = 10
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
    navigationController?.popViewController(animated: true)
    }
    
    
  
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
    }
    
}
