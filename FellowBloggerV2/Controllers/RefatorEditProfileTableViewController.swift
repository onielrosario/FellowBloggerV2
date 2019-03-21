//
//  RefatorEditProfileTableViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/21/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit

class RefatorEditProfileTableViewController: UITableViewController {
    @IBOutlet weak var editCoverImage: UIButton!
    @IBOutlet weak var editProfileImage: CircularButton!
    @IBOutlet weak var editFirstNameTF: UITextField!
    @IBOutlet weak var editLastName: UITextField!
    @IBOutlet weak var editUsername: UITextField!
    @IBOutlet weak var editGithub: UITextField!
    @IBOutlet weak var editLinkedin: UITextField!
    @IBOutlet weak var editBio: UITextView!
    var blogger: Blogger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI () {
        editLastName.text = blogger.bio
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

