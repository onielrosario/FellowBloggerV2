//
//  CommentsViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/21/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class CommentsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentUserImage: CircularImageView!
    @IBOutlet weak var textField: UITextField!
    var blog: Blog!
    weak var listener: ListenerRegistration!
    var comments = [Comment]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getcomments()
        configureUI()
    }
    
    private func getcomments() {
        DBService.GetComments(blog: blog) { (allComments, error) in
            if let error = error {
                print(error)
            } else if let allComments = allComments {
                self.comments = allComments
            }
        }
    }
    
    private func  configureUI() {
      let user = AppDelegate.authService.getCurrentUser()
        currentUserImage.kf.setImage(with: URL(string: user?.photoURL?.absoluteString ?? ""), placeholder:#imageLiteral(resourceName: "ProfilePH.png") )
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        textField.delegate = self
        let newView = UIImageView()
        newView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let icon = UIImage(named: "commentsLogo")
        newView.image = icon
        textField.rightViewMode = .whileEditing
        textField.rightView = newView
    }
    
    
    @IBAction func AddCommentPressed(_ sender: UIBarButtonItem) {
        guard let newComment = textField.text, !newComment.isEmpty else  {
            showAlert(title: nil, message: "enter a message", actionTitle: "OK")
            return
        }
        DBService.postComment(comment: newComment, blog: blog)
      navigationController?.popViewController(animated: true)
    }
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        let comment = comments[indexPath.row]
        cell.label.text = comment.commentText
        DBService.getBlogger(userId: comment.commentedBy) { (error, blogger) in
            if let error = error {
                print(error)
            } else if let blogger = blogger {
                cell.bloggerImage.kf.setImage(with: URL(string: blogger.photoURL ?? ""), placeholder: #imageLiteral(resourceName: "ProfilePH.png"))
            }
        }
        return cell
    }
}

extension CommentsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
