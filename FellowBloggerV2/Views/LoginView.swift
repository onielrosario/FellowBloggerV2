//
//  LoginView.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/14/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit

protocol loginViewDelegate: AnyObject {
    func didSelectLoginButton(_ loginView: LoginView, accountState: AccountStatus)
}

class LoginView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    public weak var delegate: loginViewDelegate?
    private var tap: UITapGestureRecognizer!
    private var accountLoginState = AccountStatus.newAccount
    
    override init(frame: CGRect) {
      super.init(frame: UIScreen.main.bounds)
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        commonInit()

    }
    
    private func  commonInit() {
        Bundle.main.loadNibNamed("Login", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loginLabel.isUserInteractionEnabled = true
        loginButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(tapGesture:)))
        loginLabel.addGestureRecognizer(tap)
    }

    
    @objc private func buttonPressed() {
        delegate?.didSelectLoginButton(self, accountState: accountLoginState)
    }
  
    @objc private func handleTap(tapGesture: UITapGestureRecognizer) {
        accountLoginState = accountLoginState == .newAccount ? .existingAccount : .newAccount
        switch accountLoginState {
        case .newAccount:
            loginButton.setTitle("Create", for: .normal)
            loginLabel.text = "Login using your account"
            nameTextField.isHidden = false
        case .existingAccount:
            nameTextField.isHidden = true
            loginButton.setTitle("Login", for: .normal)
            loginLabel.text = "New around here? Create an account"
        }
    }

}
