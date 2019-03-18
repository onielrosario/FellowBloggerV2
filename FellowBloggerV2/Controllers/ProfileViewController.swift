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
    private var listener: ListenerRegistration!
    private var blogs = [Blog]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        title = "Profile"
        super.viewDidLoad()
        configureTableView()
        profileViewHeader.delegate = self
    }
    
    
    public func getBlogs() {
//        refreshcontrol.beginRefreshing()
        listener = DBService.firestoreDB
            .collection(BlogsCollectionKeys.CollectionKey)
            .addSnapshotListener { [weak self] (snapshot, error) in
                if let error = error {
                    print("failed to get blogs with error: \(error.localizedDescription)")
                } else if let snapshot = snapshot {
                    self?.blogs = snapshot.documents.map{Blog(dict: $0.data()) }.sorted{ $0.createdDate.date() >  $1.createdDate.date() }
                }
//                DispatchQueue.main.async {
//                    self?.refreshcontrol.endRefreshing()
//                }
        }
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
        
        return cell
    }
}
extension ProfileViewController: ProfileHeaderViewDelegate {
    func willSignOut(_ profileHeaderView: ProfileView) {
        authservice.signOutAccount()
    }
    
    func willEditProfile(_ profileHeaderView: ProfileView) {
        pushControllers(controller: "EditVC")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My posts"
    }
    
    
}
