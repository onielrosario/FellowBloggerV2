//
//  SearchFellowResultController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/15/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit
import Firebase

class SearchFellowResultController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var bloggers = [Blogger]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var authservice = AppDelegate.authService
    private var listener: ListenerRegistration!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableview()
        getBloggers()
    }
    
    private func  getBloggers() {
        DBService.firestoreDB.collection(BloggersCollectionKeys.CollectionKey)
            .getDocuments { [weak self] (snapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let snapshot = snapshot {
                    self?.bloggers = snapshot.documents.map{ Blogger(dict: $0.data())}
                }
        }
    }
    
    private func filterFellows(text: String) -> [Blogger] {
        var newBloggers = [Blogger]()
        for blogger in bloggers {
            if (blogger.firstName?.lowercased().contains(text))! || (blogger.lastName?.lowercased().contains(text))! || blogger.displayName.lowercased().contains(text) {
                newBloggers.append(blogger)
            }
        }
        return newBloggers
    }
    
    
    private func  configureTableview() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
}

extension SearchFellowResultController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension SearchFellowResultController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bloggers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fellowSearchCell", for: indexPath)
        let blogger = bloggers[indexPath.row]
        cell.textLabel?.text = blogger.displayName
        cell.detailTextLabel?.text = blogger.fullName
        configureCellImage(cell: cell, blogger: blogger)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
        let blogger = bloggers[indexPath.row]
        profileVC.blogger = blogger
        navigationController?.pushViewController(profileVC, animated: true)
//    self.present(profileVC, animated: true)
    }
    
    private func configureCellImage(cell: UITableViewCell, blogger: Blogger) {
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.cornerRadius = (cell.imageView?.bounds.width)! / 2.0
        cell.imageView?.layer.borderColor = UIColor.lightGray.cgColor
        cell.imageView?.layer.borderWidth = 0.5
        cell.imageView?.clipsToBounds = true
        cell.imageView?.kf.setImage(with: URL(string: blogger.photoURL ?? ""), placeholder:#imageLiteral(resourceName: "ProfilePH.png") )
    }
    
    
}

extension SearchFellowResultController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchBar.delegate = self
       guard let fellowsSearched = searchController.searchBar.text?.lowercased(),
        !fellowsSearched.isEmpty else {
            getBloggers()
            return
        }
       self.bloggers = filterFellows(text: fellowsSearched)
    }
}

extension SearchFellowResultController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            getBloggers()
            return
        }
       self.bloggers = filterFellows(text: text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.bloggers = filterFellows(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            getBloggers()
            return
        }
        self.bloggers = filterFellows(text: text)
    }
}
