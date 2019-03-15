//
//  EditViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/15/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editProfileButton: CircularButton!
    @IBOutlet weak var editCoverImage: UIImageView!
    private var editLabels: [String] = ["First Name","Last Name","Username","Bio"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    configureTableview()
    }
    private func configureTableview() {
        tableView.dataSource = self
        tableView.delegate = self
        
    }
}

extension EditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as? EditCell else {
            return UITableViewCell()
        }
        let labelTitle = editLabels[indexPath.row]
        cell.editLabel.text = labelTitle
        return cell
    }
    
    
    
}

extension EditViewController: UITableViewDelegate {
    
}
