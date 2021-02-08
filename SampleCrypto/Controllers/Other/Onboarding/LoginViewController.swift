//
//  LoginViewController.swift
//  SampleCrypto
//
//  Created by Administrator on 1/31/21.
//

import FBSDKLoginKit
import FirebaseAuth
import JGProgressHUD
import UIKit


class LoginViewController: UIViewController, LoginButtonDelegate{

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    private let spinner = JGProgressHUD(style: .dark)
    
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
                                                 parameters: ["fields":
                                                                "email,first_name,last_name,picture.type(large)"],
                                                 tokenString: token,
                                                 version: nil,
                                                 httpMethod: .get)
        
        facebookRequest.start { (_, result, error) in
            guard let result = result as? [String:Any],
                error == nil else{
                print("Failed to make facebook graph request")
                return
            }
            print(result)
            
            //result prints out response from facebook
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String:Any],
                  let data = picture["data"] as? [String:Any],
                  let pictureUrl = data["url"] as? String else{
                    print ("Failed to get email and name from fb result")
                    return
            }
            
            //store user email
            UserDefaults.standard.set(email, forKey: "email")

            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists{
                    let user = User(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: user) { success in
                        if success{
                            
                            guard let url = URL(string: pictureUrl) else{
                                return
                            }
                            
                            print("Downloading data from facebook image")
                            
                            URLSession.shared.dataTask(with: url, completionHandler: {data, _, _ in
                                guard let data = data else{
                                    print("Failed to get data from facebook")
                                    return
                                }
                                
                                print("Got data from FB and uploading...")
                                
                                //upload image to storage
                                let fileName = user.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) {
                                    result in
                                    switch result{
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                }
                            }).resume()
                        }
                    }
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
        spinner.show(in: view)
        Auth.auth().signIn(withEmail: email, password: password) { [weak self](authResult, error) in
            guard let strongSelf = self else{
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else{
                print("failed to log in user with email: \(email)")
                let alert = UIAlertController(title: "Error",
                                              message: "Failed to log in user with email: \(email)",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: nil))
                strongSelf.present(alert, animated: true, completion: nil)
                return
            }
            
            let user = result.user
            
            //store standard user email
            UserDefaults.standard.set(email, forKey: "email")
            
            print("Logged in \(user)")
            strongSelf.navigationController?.dismiss(animated: true)
            
            if !UserDefaults.standard.bool(forKey: "user_onboarded"){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginSuccess") , object: nil)
            }
        }
    }
}
