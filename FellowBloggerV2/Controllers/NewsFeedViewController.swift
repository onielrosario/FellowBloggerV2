//
//  NewsFeedViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/14/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit

class NewsFeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    private func  configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
 
    @IBAction func addBlog(_ sender: UIBarButtonItem) {
        
    }
}

extension NewsFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
}

extension NewsFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as? FeedCell else { return UITableViewCell() }
        return cell
    }
    
    
}
