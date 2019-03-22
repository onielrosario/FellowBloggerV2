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
import MessageUI

class ProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! 
    private lazy var profileViewHeader: ProfileView = {
        let headerView = ProfileView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500))
        return headerView
    }()
    private let authservice = AppDelegate.authService
    private var user: User!
    var blogger: Blogger!
    var github: String?
    var linkedIn: String?
    var mail: String?
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
                          self.blogger = blogger
                        self.profileViewHeader.profileImage.kf.setImage(with: URL(string: blogger.photoURL ?? ""), placeholder:#imageLiteral(resourceName: "ProfilePH.png") )
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
    
    private func pushControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "refactorEditVC") as! RefatorEditProfileTableViewController
      destinationVC.blogger = self.blogger
         self.navigationController?.pushViewController(destinationVC, animated: true)
            }
    

    
    @IBAction func unwindFromEditViewController(segue: UIStoryboardSegue) {
    let editVC = segue.source as! RefatorEditProfileTableViewController
        if user != nil {
            profileViewHeader.profileImage.image = editVC.editProfileImage.currentImage
            profileViewHeader.coverImage.image = editVC.editCoverImage.currentImage
            profileViewHeader.fullNameLabel.text = "\(editVC.editFirstNameTF.text ?? "") \(editVC.editLastName.text ?? "")"
            profileViewHeader.bloggerName.text = "@" + editVC.editUsername.text!
            profileViewHeader.bioText.text = editVC.editBio.text
            self.github = editVC.editGithub.text
            self.linkedIn = editVC.editLinkedin.text
        }
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
extension ProfileViewController: ProfileHeaderViewDelegate, MFMailComposeViewControllerDelegate {
    func linkedInPressed(_ profileHeaderView: ProfileView) {
       UIApplication.shared.canOpenURL(NSURL (string: blogger.linkedIn ?? "")! as URL)
    }
    
    func emailPressed(_ profileHeaderView: ProfileView) {
        let emailTitle = "Hello!"
        let recipients = ["\(String(describing: user.email))"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setToRecipients(recipients)
       self.present(mc, animated: true, completion: nil)
    }
    
    func githubPressed(_ profileHeaderView: ProfileView) {
         UIApplication.shared.canOpenURL(NSURL (string: blogger.linkedIn ?? "")! as URL)
    }
    
    func willSignOut(_ profileHeaderView: ProfileView) {
        authservice.signOutAccount()
        showLoginView()
        
    }
    
    func willEditProfile(_ profileHeaderView: ProfileView) {
        pushControllers()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My posts"
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
    
    
}
