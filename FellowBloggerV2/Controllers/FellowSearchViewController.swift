//
//  FellowSearchViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/14/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit

class FellowSearchViewController: UIViewController {
    private var searchFellowsVC: SearchFellowResultController = {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fellowSearchResultsVC = storyboard.instantiateViewController(withIdentifier: "fellowSearchedVC") as! SearchFellowResultController
        return fellowSearchResultsVC
    }()
    private lazy var searchBarController: UISearchController = {
        let sc = UISearchController(searchResultsController: UINavigationController.init(rootViewController: searchFellowsVC))
        sc.searchResultsUpdater =  searchFellowsVC
        sc.hidesNavigationBarDuringPresentation = false
        sc.searchBar.placeholder = "Search for fellows"
        sc.dimsBackgroundDuringPresentation = false
        sc.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        sc.searchBar.autocapitalizationType = .none
        return sc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchBarController
    }
    
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
searchBarController.searchBar.resignFirstResponder()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    

}
