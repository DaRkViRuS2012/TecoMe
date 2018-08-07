//
//  LoginViewController.swift
//  Wardah
//
//  Created by Hani on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit

class LoginViewController: AbstractController {

    // MARK: Properties
    // login view
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var emailTextField: XUITextField!
    @IBOutlet weak var passwordTextField: XUITextField!

   
    // Center View
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var loginButton: XUIButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    // footer view
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var signupButton: XUIButton!
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBarTitle(title: "Login".localized)
        //self.showNavCloseButton = true
    }
    
    // Customize all view members (fonts - style - text)
    override func customizeView() {
        super.customizeView()
        // set fonts
        loginButton.titleLabel?.font = AppFonts.normalSemiBold

        
     
        // set text
//        loginButton.setTitle("START_NORMAL_LOGIN".localized, for: .normal)
//        loginButton.setTitle("START_NORMAL_LOGIN".localized, for: .highlighted)
//        
//        forgetPasswordButton.setTitle("START_FORGET_PASSWORD".localized, for: .normal)
//        forgetPasswordButton.setTitle("START_FORGET_PASSWORD".localized, for: .highlighted)
//        signupButton.setTitle("START_CREATE_ACCOUNT".localized, for: .normal)
//        signupButton.setTitle("START_CREATE_ACCOUNT".localized, for: .highlighted)
//        emailTextField.placeholder = "START_EMAIL_PLACEHOLDER".localized
//        passwordTextField.placeholder = "START_PASSWORD_PLACEHOLDER".localized
//
        // text field styles
        emailTextField.appStyle()
        passwordTextField.appStyle()
        
        // customize button
        loginButton.makeRounded()
        
        
        
        
        passwordTextField.addIconButton(image: "eyeIcon")
        let passwordTextFieldRightButton = passwordTextField.rightView as! UIButton
        passwordTextFieldRightButton.addTarget(self, action: #selector(showOrHideText), for: .touchUpInside)
        
        // set Colors
        loginButton.backgroundColor = AppColors.primary
    }
    
    
    @objc func showOrHideText(){
        self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
    }
    
    
    // Build up view elements
    override func buildUp() {
        loginView.animateIn(mode: .animateInFromBottom, delay: 0.2)
        centerView.animateIn(mode: .animateInFromBottom, delay: 0.3)
        footerView.animateIn(mode: .animateInFromBottom, delay: 0.4)
    }
    
    // MARK: Actions
    @IBAction func loginAction(_ sender: XUIButton) {
        // validate email
        if let email = emailTextField.text, !email.isEmpty {
                // validate password
                if let password = passwordTextField.text, !password.isEmpty {
                    if password.length >= 1 {
                        // start login process
                        self.showActivityLoader(true)
                        
                        ApiManager.shared.userLogin(email: email, password: password) { (isSuccess, error, user) in
                            // stop loading
                            self.showActivityLoader(false)
                            
                            // login success
                            if (isSuccess) {
                                    //self.dismiss(animated: true, completion: nil)
                                self.performSegue(withIdentifier: "loginhomeSegue", sender: nil)
//                                self.popOrDismissViewControllerAnimated(animated: true)                                
                            } else {
                                if let msg = error?.message{
                                    self.showMessage(message: msg , type: .error)
                                    
                                }
                            }
                        }
                    } else {
                        showMessage(message:"SINGUP_VALIDATION_PASSWORD_LENGHTH".localized, type: .warning)
                    }
                } else {
                    showMessage(message:"please enter your password".localized, type: .warning)
                }
            
        } else {
            showMessage(message:"please enter your user name and password".localized, type: .warning)
        }
    }
    


    
    // MARK: textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            loginAction(loginButton)
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

