//
//  ProfileView.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/14/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit


protocol ProfileHeaderViewDelegate: AnyObject {
    func willSignOut(_ profileHeaderView: ProfileView)
    func willEditProfile(_ profileHeaderView: ProfileView)
    func linkedInPressed(_ profileHeaderView: ProfileView)
    func emailPressed(_ profileHeaderView: ProfileView)
    func githubPressed(_ profileHeaderView: ProfileView)
}



class ProfileView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var profileImage: CircularImageView!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var bloggerName: UILabel!
    @IBOutlet weak var bioText: UITextView!
    @IBOutlet weak var fullNameLabel: UILabel!
    weak var delegate: ProfileHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        commonInit()

    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ProfileHeader", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        
    }
    
    @IBAction func signOutPressed(_ sender: UIButton) {
        delegate?.willSignOut(self)
    }
    
    @IBAction func editPressed(_ sender: UIButton) {
        delegate?.willEditProfile(self)
    }
    
    
    @IBAction func linkedInPressed(_ sender: UIButton) {
        delegate?.linkedInPressed(self)
    }
    
    @IBAction func emailPressed(_ sender: UIButton) {
    delegate?.emailPressed(self)
    
    }
    
    
    @IBAction func github(_ sender: UIButton) {
        delegate?.githubPressed(self)
    }
}
