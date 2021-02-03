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
    
    private let fbLoginButton: FBLoginButton = {
        let fbButton = FBLoginButton()
        fbButton.permissions = ["public_profile", "email"]
        return fbButton
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
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
        
        //fb button set up
        fbLoginButton.frame = CGRect(x: 0,
                                     y: 0,
                                     width: loginButton.frame.size.width,
                                     height: loginButton.frame.size.height)
        fbLoginButton.center = view.center
        fbLoginButton.delegate = self
        view.addSubview(fbLoginButton)
    }
    
    private func showError(_ message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else{
            showError("User failed to log in with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                 parameters: ["fields": "email,name"],
                                                 tokenString: token,
                                                 version: nil,
                                                 httpMethod: .get)
        facebookRequest.start { (_, result, error) in
            guard let result = result as? [String:Any],
                error == nil else{
                print("Failed to make facebook graph request")
                return
            }
            print("\(result)")
            
            guard let userName = result["name"] as? String,
                let email = result["email"] as? String else{
                    print ("Failed to get email and name from fb result")
                    return
            }
            
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else{
                return
            }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists{
                    DatabaseManager.shared.insertUser(with: User(firstName: firstName,
                                                                 lastName: lastName,
                                                                 emailAddress: email))
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            Auth.auth().signIn(with: credential) { [weak self](authResult, error) in
                
                guard let strongSelf = self else{
                    return
                }
                
                guard authResult != nil, error == nil else{
                    print("Facebook credential login failed, MFA may be needed")
                    return
                }
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginSuccess") , object: nil)
            }
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
