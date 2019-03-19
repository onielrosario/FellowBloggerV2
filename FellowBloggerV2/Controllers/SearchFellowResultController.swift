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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearch()
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

    
    private func  configureTableview() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
    }
    private func configureSearch() {
        
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
        
        return cell
    }
    
    private func configureCellImage(cell: UITableViewCell) {
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.cornerRadius = cell.bounds.width / 2.0
        cell.imageView?.layer.borderColor = UIColor.lightGray.cgColor
        cell.imageView?.layer.borderWidth = 0.5
        cell.imageView?.clipsToBounds = true
    }
    
    
}

extension SearchFellowResultController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    
}
