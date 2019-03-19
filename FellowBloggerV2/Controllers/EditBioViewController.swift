//
//  EditBioViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/15/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit

class EditBioViewController: UIViewController {
    @IBOutlet weak var editBioTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
      performSegue(withIdentifier: "unwind from edit bio vc", sender: self)
    }
    
}
