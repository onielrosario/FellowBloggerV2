//
//  LoginViewController.swift
//  FellowBloggerV2
//
//  Created by Oniel Rosario on 3/14/19.
//  Copyright © 2019 Oniel Rosario. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

enum AccountStatus {
    case newAccount
    case existingAccount
}

class LoginViewController: UIViewController {
let loginView = LoginView()
    private var authservice =  AppDelegate.authService
    private var blogger: Blogger!
    private var accountLoginState = AccountStatus.newAccount
    
    override func viewDidLoad() {
        super.viewDidLoad()
    view.addSubview(loginView)
    loginView.delegate = self
    loginView.nameTextField.delegate = self
    loginView.emailTextField.delegate = self
    loginView.passwordTextfield.delegate = self
    authservice.authserviceCreateNewAccountDelegate = self
    authservice.authserviceExistingAccountDelegate = self
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let name = loginView.nameTextField.text,
        let email = loginView.emailTextField.text,
        let password = loginView.passwordTextfield.text,
            !name.isEmpty, !email.isEmpty, !password.isEmpty else {
               showAlert(title: "Missing Fields", message: "all fields required", actionTitle: "OK")
                return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
        textField.becomeFirstResponder()
    }
}

extension LoginViewController: loginViewDelegate {
    func didSelectLoginButton(_ loginView: LoginView, accountState: AccountStatus) {
        guard let email = loginView.emailTextField.text,
        let pasword = loginView.passwordTextfield.text,
            let name = loginView.nameTextField.text else {
                return
        }
        switch accountState {
        case .newAccount:
            guard !name.isEmpty, !email.isEmpty, !pasword.isEmpty else {
               showAlert(title: "Missing fields", message: "all fields required", actionTitle: "Try again")
                return
            }
            authservice.createNewAccount(username: name, email: email, password: pasword)
        case .existingAccount:
            guard !email.isEmpty, !pasword.isEmpty else {
                showAlert(title: "Missing fields", message: "all fields required", actionTitle: "Try again")
                return
            }
            authservice.signInExistingAccount(email: email, password: pasword)
        }
    }
}

extension LoginViewController: AuthServiceCreateNewAccountDelegate {
    func didRecieveErrorCreatingAccount(_ authservice: AuthService, error: Error) {
        showAlert(title: "error creating account", message: error.localizedDescription, actionTitle: "try again")
    }
    
    func didCreateNewAccount(_ authservice: AuthService, blogger: Blogger) {
        showAlert(title: "Account Created", message: "account created using: \(blogger.email)", style: .alert) { (alert) in
            self.presentMainTabController()
        }
    }
    
    private func presentMainTabController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabVC = storyboard.instantiateViewController(withIdentifier: "MainTab") as! MainTabController
        mainTabVC.modalTransitionStyle = .crossDissolve
        mainTabVC.modalPresentationStyle = .overFullScreen
        self.present(mainTabVC, animated: true)
    }
}

extension LoginViewController: AuthServiceExistingAccountDelegate {
    func didRecieveErrorSigningToExistingAccount(_ authservice: AuthService, error: Error) {
        showAlert(title: "sign in error", message: error.localizedDescription, actionTitle: "try again")
    }
    
    func didSignInToExistingAccount(_ authservice: AuthService, user: User) {
        self.presentMainTabController()
    }
}
