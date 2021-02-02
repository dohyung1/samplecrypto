//
//  LoginViewController.swift
//  SampleCrypto
//
//  Created by Administrator on 1/31/21.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth


class LoginViewController: UIViewController, LoginButtonDelegate{

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
        if let token = AccessToken.current,!token.isExpired {

            let token = token.tokenString
            
            let request = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                     parameters: ["fields": "email,name"],
                                                     tokenString: token,
                                                     version: nil,
                                                     httpMethod: .get)
            request.start { (connection, result, error) in
                print("\(result)")
            }
        }
        else{
            let loginButton = FBLoginButton()
            loginButton.center = view.center
            loginButton.delegate = self
            loginButton.permissions = ["public_profile", "email"]
            view.addSubview(loginButton)
        }
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setUpElements(){
        title = "Log in"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        //Hide error label
        errorLabel.alpha = 0
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    private func showError(_ message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        let token = result?.token?.tokenString
        
        let request = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                 parameters: ["fields": "email,name"],
                                                 tokenString: token,
                                                 version: nil,
                                                 httpMethod: .get)
        request.start { (connection, result, error) in
            print("\(result)")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    @objc private func didTapRegister(){
        guard let registerVC = storyboard?.instantiateViewController(identifier: "register") as? RegistrationViewController else{
            print("failed to get register from storyboard")
            return
        }
        registerVC.title = "Create Account"
        navigationController?.pushViewController(registerVC, animated: true)
    }
    

    @IBAction func loginButtonTapped(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty, password.count >= 8 else{
            
            showError("Email or password is incorrect. \n Please try again.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self](authResult, error) in
            guard let strongSelf = self else{
                return
            }
            guard let result = authResult, error == nil else{
                print("failed to log in user with email: \(email)")
                return
            }
            
            let user = result.user
            print("Logged in \(user)")
            strongSelf.navigationController?.dismiss(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginSuccess") , object: nil)
            
        }
    }
}
