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
    private let authservice = AppDelegate.authService
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
    
    @IBAction func unwindFromAddViewController(segue: UIStoryboardSegue) {
        let editVC = segue.source as! EditBloggViewController
        detailBlogImage.image = editVC.newBlogImage.image
        blogDescription.text = editVC.blogDescription.text
    }

    
    @IBAction func settingsPressed(_ sender: UIButton) {
        guard let user = authservice.getCurrentUser() else {
           print("no logged user")
            return
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let saveImage = UIAlertAction(title: "Save Image", style: .default) { [unowned self](action) in
            if let image = self.detailBlogImage.image {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
        let editAction = UIAlertAction(title: "Edit", style: .default) { [unowned self] (action) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let editVC = storyboard.instantiateViewController(withIdentifier: "AddBlogVC") as! EditBloggViewController
            editVC.blog = self.blog
            editVC.editblogDescription = self.blogDescription.text
            editVC.editImage = self.detailBlogImage.image
            self.navigationController?.pushViewController(editVC, animated: true)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (delete) in
            self.confirmDeletionActionSheet(handler: { (action) in
                self.executeDelete()
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(saveImage)
        if user.uid == self.blog.bloggerId {
            alertController.addAction(editAction)
            alertController.addAction(deleteAction)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
        
    }

    
    private func executeDelete() {
        DBService.deleteBlog(blog: blog) { [weak self](error) in
            if let error = error {
                self?.showAlert(title: "error deliting blog", message: error.localizedDescription, actionTitle: "OK")
            } else {
                self?.showAlert(title: "Blog deleted", message: nil, style: .alert, handler: { (action) in
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        }
    }

}
