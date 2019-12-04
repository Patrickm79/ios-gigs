//
//  LoginViewController.swift
//  iOS-Gigs
//
//  Created by Patrick Millet on 12/4/19.
//  Copyright © 2019 Patrick Millet. All rights reserved.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}

class LoginViewController: UIViewController {
    //MARK: - Outlets
    
    @IBOutlet weak var signInUpSegmentedControl: UISegmentedControl!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInUpButton: UIButton!
    
    
    //MARK: - Properties
    
    var apiController: GigController?
    var loginType = LoginType.signUp
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Actions
    
    @IBAction func signInUpButtonTapped(_ sender: Any) {
        guard let apiController = apiController else { return }
        
        if let username = usernameTextField.text, !username.isEmpty,
            let password = passwordTextField.text, !password.isEmpty {
            let user = User(username: username, password: password)
        
        if loginType == .signUp {
            apiController.signUp(with: user) { (error) in
                if let error = error {
                    print("Error occured during sign up: \(error)")
                } else {
                    let alertController = UIAlertController(title: "Sign Up Successful", message: "Now please log in", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true) {
                        self.loginType = .signIn
                        self.signInUpSegmentedControl.selectedSegmentIndex = 1
                        self.signInUpButton.setTitle("Sign In", for: .normal)
                    }
                }
            }
        } else {
            apiController.signIn(with: user) { (error) in
                if let error = error {
                    print("Error occured during sign in: \(error)")
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
    
    @IBAction func signInUpChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            loginType = .signUp
            signInUpButton.setTitle("Sign Up", for: .normal)
        } else {
            loginType = .signIn
            signInUpButton.setTitle("Sign In", for: .normal)
            }
        }
    }

