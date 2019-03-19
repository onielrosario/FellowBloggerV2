//
//  NewsFeedViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/14/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class NewsFeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var blogs = [Blog]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var bloggers = [Blogger]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var listener: ListenerRegistration!
    private var authservice = AppDelegate.authService
    private lazy var refreshcontrol: UIRefreshControl = {
        let rc = UIRefreshControl()
        tableView.refreshControl = rc
        rc.addTarget(self, action: #selector(getBlogs), for: .valueChanged)
        return rc
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        getBlogs()
    }
    
    
    @objc public func getBlogs() {
        refreshcontrol.beginRefreshing()
        listener = DBService.firestoreDB
            .collection(BlogsCollectionKeys.CollectionKey)
            .addSnapshotListener { [weak self] (snapshot, error) in
                if let error = error {
                    print("failed to get blogs with error: \(error.localizedDescription)")
                } else if let snapshot = snapshot {
                    self?.blogs = snapshot.documents.map{Blog(dict: $0.data()) }.sorted{ $0.createdDate.date() >  $1.createdDate.date() }
                }
                DispatchQueue.main.async {
                    self?.refreshcontrol.endRefreshing()
                }
        }
        listener = DBService.firestoreDB
        .collection(BloggersCollectionKeys.CollectionKey)
            .addSnapshotListener { [weak self] (snapshot, error) in
                if let error = error {
                    print("failed to get blogs with error: \(error.localizedDescription)")
                } else if let snapshot = snapshot {
                    self?.bloggers = snapshot.documents.map{ Blogger(dict: $0.data())}
                    
                }
            }
    }
    
    private func  configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func pushControllers(controller: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: controller)
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail segue" {
            guard let indexPath = sender as? IndexPath,
            let cell = tableView.cellForRow(at: indexPath) as? FeedCell,
                let navController = segue.destination as? UINavigationController,
            let detailViewController = navController.viewControllers.first as? DetailViewController else {
                    fatalError("cannot segue to detail")
            }
        let blog = blogs[indexPath.row]
        detailViewController.blog = blog
    }
    }
    
    @IBAction func addBlog(_ sender: UIBarButtonItem) {
        pushControllers(controller: "AddBlogVC")
    }
}

extension NewsFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
}

extension NewsFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as? FeedCell else { return UITableViewCell() }
   let blog = blogs[indexPath.row]
        cell.feedDescription.text = blog.blogDescription
        cell.feedPhoto.kf.setImage(with: URL(string: blog.imageURL), placeholder: #imageLiteral(resourceName: "tealCover.jpg"))
      fetchBlogCreatorPhoto(userid: blog.bloggerId, cell: cell, blog: blog)
        return cell
    }
    
    private func fetchBlogCreatorPhoto(userid: String, cell: FeedCell, blog: Blog) {
        DBService.getBlogger(userId: userid) { (error, blogger) in
            if let error = error {
                print("failed to get blogger with error: \(error.localizedDescription)")
            } else if let blogger = blogger {
              DBService.firestoreDB.collection(BlogsCollectionKeys.CreatedDateKey)
                .whereField(BlogsCollectionKeys.BloggerIdKey, isEqualTo: blogger.bloggerId)
                cell.profilePhoto.kf.setImage(with: URL(string: blogger.photoURL ?? "no image"), placeholder: #imageLiteral(resourceName: "ProfilePH.png"))
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   performSegue(withIdentifier: "detail segue", sender: indexPath)
    }
}

