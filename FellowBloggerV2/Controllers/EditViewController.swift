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
   var tap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    configureTableview()
    }
    private func configureTableview() {
        tableView.dataSource = self
        tableView.delegate = self
         tableView.tableFooterView = UIView()
        
    }
    
    private func pushControllers(controller: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: controller)
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
navigationController?.popViewController(animated: true)
    }
    
    
    
}

extension EditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editLabels.count
    }
    @objc private func textFieldTapped() {
        pushControllers(controller: "EditBioVC")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BioCell", for: indexPath) as? BioCell else { return UITableViewCell() }
            tap = UITapGestureRecognizer(target: self, action: #selector(textFieldTapped))
            
            
            cell.bioTextField.addGestureRecognizer(tap)
            
            
            
            return cell
        default:
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as? EditCell else {
            return UITableViewCell()
        }
        let labelTitle = editLabels[indexPath.row]
        cell.editLabel.text = labelTitle
        return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let editBioVC = storyboard.instantiateViewController(withIdentifier: "EditBioVC")
            navigationController?.pushViewController(editBioVC, animated: true)
        }
    }
}

extension EditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 90
        } else {
            return 50
        }
    }
}
