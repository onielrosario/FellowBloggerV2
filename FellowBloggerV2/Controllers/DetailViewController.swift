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
    @IBOutlet weak var blogDescription: UILabel!
    @IBOutlet weak var commentsButton: UIButton!
    var blog: Blog!
    private let authservice = AppDelegate.authService
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDetailVC()
        updateUI()
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
    
    private func updateUI() {
        DBService.GetComments(blog: blog) { (comments, error) in
            if let error = error {
                print(error)
            } else if let comments = comments {
                let count = comments.count
                if count > 0 {
                     self.commentsButton.setTitle("view all \(count) comments", for: .normal)
                } else  {
                      self.commentsButton.setTitle("leave the first comment", for: .normal)
                }
            }
        }
    }
    
    @IBAction func unwindFromAddViewController(segue: UIStoryboardSegue) {
        let editVC = segue.source as! EditBlogViewController
        detailBlogImage.image = editVC.newBlogImage.image
        blogDescription.text = editVC.blogDescription.text
    }
    
    
    @IBAction func commentPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commentVC = storyboard.instantiateViewController(withIdentifier: "customCommentsVC") as! CommentsViewController
        commentVC.blog = blog
        navigationController?.pushViewController(commentVC, animated: true)
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
            let editVC = storyboard.instantiateViewController(withIdentifier: "AddBlogVC") as! EditBlogViewController
            editVC.blog = self.blog
            editVC.editblogDescription = self.blogDescription.text ?? ""
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
