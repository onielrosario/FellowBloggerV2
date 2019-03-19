//
//  DetailViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/18/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class DetailViewController: UIViewController {
    @IBOutlet weak var detailBlogImage: UIImageView!
    @IBOutlet weak var bloggerimage: CircularImageView!
    @IBOutlet weak var bloggerName: UILabel!
    @IBOutlet weak var blogDescription: UITextView!
    var blog: Blog!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDetailVC()
    }
    func configureDetailVC() {
        detailBlogImage.kf.setImage(with: URL(string: blog.imageURL), placeholder:#imageLiteral(resourceName: "tealCover.jpg") )
        blogDescription.text = blog.blogDescription
        DBService.getBlogger(userId: blog.bloggerId) { (error, blogger) in
            if let error = error {
                print(error.localizedDescription)
            } else if let blogger = blogger {
                self.bloggerName.text = blogger.displayName
                self.bloggerimage.kf.setImage(with: URL(string: blogger.photoURL ?? ""), placeholder: #imageLiteral(resourceName: "ProfilePH.png"))
            }
        
        }
    }

    
    @IBAction func settingsPressed(_ sender: UIButton) {
        
    }
    

}
