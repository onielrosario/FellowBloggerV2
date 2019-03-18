//
//  DetailViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/18/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var detailBlogImage: UIImageView!
    @IBOutlet weak var bloggerimage: CircularImageView!
    @IBOutlet weak var bloggerName: UILabel!
    
    @IBOutlet weak var blogDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func settingsPressed(_ sender: UIButton) {
        
    }
    

}
