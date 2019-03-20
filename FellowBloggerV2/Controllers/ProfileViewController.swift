//
//  ViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/13/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! 
    private lazy var profileViewHeader: ProfileView = {
        let headerView = ProfileView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 450))
        return headerView
    }()
    private let authservice = AppDelegate.authService
    private var user: User!
    var blogger: Blogger!
    private var listener: ListenerRegistration!
    private var blogs = [Blog]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
          title = "Profile"
        configureTableView()
        profileViewHeader.delegate = self
        getBlogs()
    }
    
    
    public func getBlogs() {
        if blogger != nil {
             navigationController?.navigationBar.isHidden = false
            title = blogger.displayName
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(CancelPressed))
            self.profileViewHeader.editButton.isHidden = true
            self.profileViewHeader.signOutButton.isHidden = true
            DBService.getBlogger(userId: blogger.bloggerId) { (error, blogger) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let blogger = blogger {
                    self.profileViewHeader.profileImage.kf.setImage(with: URL(string: blogger.photoURL ?? ""), placeholder:#imageLiteral(resourceName: "ProfilePH.png") )
                    self.profileViewHeader.bioText.text = blogger.bio
                    self.profileViewHeader.fullNameLabel.text = "\(blogger.fullName)"
                    self.profileViewHeader.bloggerName.text = "@\(blogger.displayName)"
                    self.profileViewHeader.coverImage.kf.setImage(with: URL(string: blogger.coverImageURL ?? ""), placeholder: #imageLiteral(resourceName: "tealCover.jpg") )
                }
            }
            listener = DBService.firestoreDB.collection(BlogsCollectionKeys.CollectionKey)
                .whereField(BlogsCollectionKeys.BloggerIdKey, isEqualTo: blogger.bloggerId)
                .addSnapshotListener { (snapshot, error) in
                    if let error = error {
                        print("failed to get blogs with error: \(error.localizedDescription)")
                    } else if let snapshot = snapshot {
                        self.blogs = snapshot.documents.map{Blog(dict: $0.data()) }.sorted{ $0.createdDate.date() >  $1.createdDate.date() }
                    }
                }
            
        } else  {
            if let user = self.authservice.getCurrentUser() {
                listener = DBService.firestoreDB
                    .collection(BlogsCollectionKeys.CollectionKey)
                    .whereField(BlogsCollectionKeys.BloggerIdKey, isEqualTo: user.uid)
                    .addSnapshotListener { [weak self] (snapshot, error) in
                        if let error = error {
                            print("failed to get blogs with error: \(error.localizedDescription)")
                        } else if let snapshot = snapshot {
                            self?.blogs = snapshot.documents.map{Blog(dict: $0.data()) }.sorted{ $0.createdDate.date() >  $1.createdDate.date() }
                        }
                }
                self.user = user
                DBService.getBlogger(userId: user.uid) { (error, blogger) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let blogger = blogger {
                        self.profileViewHeader.profileImage.kf.setImage(with: URL(string: user.photoURL?.absoluteString ?? ""), placeholder:#imageLiteral(resourceName: "ProfilePH.png") )
                        self.profileViewHeader.bioText.text = blogger.bio
                        self.profileViewHeader.fullNameLabel.text = "\(blogger.fullName)"
                        self.profileViewHeader.bloggerName.text = "@\(blogger.displayName)"
                        self.profileViewHeader.coverImage.kf.setImage(with: URL(string: blogger.coverImageURL ?? ""), placeholder: #imageLiteral(resourceName: "tealCover.jpg") )
                    }
                }
            }
        }
    }
    
    @objc private func CancelPressed() {
        self.dismiss(animated: true)
    }
    
    private func configureTableView() {
        tableView.tableHeaderView = profileViewHeader
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
    }
    
    private func pushControllers(controller: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: controller)
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @IBAction func unwindFromEditViewController(segue: UIStoryboardSegue) {
    let editVC = segue.source as! EditViewController
      profileViewHeader.profileImage.image = editVC.editProfileButton.currentImage
     profileViewHeader.coverImage.image = editVC.editCoverImage.image
    profileViewHeader.fullNameLabel.text = "\(editVC.editTextFields[0]) \(editVC.editTextFields[1])"
        profileViewHeader.bloggerName.text = "@\(editVC.editTextFields[2])"
        profileViewHeader.bioText.text = editVC.bio
    }
}


extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450
        
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell else {
            return UITableViewCell()
        }
        let blog = blogs[indexPath.row]
        cell.blogDescription.text = blog.blogDescription
        cell.blogImage.kf.setImage(with: URL(string: blog.imageURL), placeholder: #imageLiteral(resourceName: "tealCover.jpg"))
        user = authservice.getCurrentUser()
        if blogger != nil {
            cell.profileImage.kf.setImage(with: URL(string: blogger.photoURL ?? ""), placeholder: #imageLiteral(resourceName: "ProfilePH.png"))
        } else if let userPhoto = user.photoURL?.absoluteString {
             cell.profileImage.kf.setImage(with: URL(string: userPhoto), placeholder: #imageLiteral(resourceName: "ProfilePH.png"))
        }
        return cell
    }
}
extension ProfileViewController: ProfileHeaderViewDelegate {
    func willSignOut(_ profileHeaderView: ProfileView) {
        authservice.signOutAccount()
        showLoginView()
        
    }
    
    func willEditProfile(_ profileHeaderView: ProfileView) {
        pushControllers(controller: "EditVC")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My posts"
    }
    
    
}
