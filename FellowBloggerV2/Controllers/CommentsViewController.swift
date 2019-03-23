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
        configureTableView()
    }
    
    private func getcomments() {
        DBService.GetComments(blog: blog) { (allComments, error) in
            if let error = error {
                print(error)
            } else if let allComments = allComments {
                self.comments = allComments
//                print(self.comments.count)
            }
        }
    }
    
    private func  configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 80
    }
    
    
    @IBAction func AddCommentPressed(_ sender: UIBarButtonItem) {
        
    }
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
