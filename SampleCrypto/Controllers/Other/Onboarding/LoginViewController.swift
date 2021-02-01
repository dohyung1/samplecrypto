//
//  LoginViewController.swift
//  SampleCrypto
//
//  Created by Administrator on 1/31/21.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
    }
    
    private func setUpElements(){
        
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

    @IBAction func loginButtonTapped(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty, password.count >= 8 else{
            
            showError("Email or password is incorrect. \n Please try again.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            DispatchQueue.main.async {
                if error == nil{
                    //user logged in
                    self.presentingViewController!.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginSuccess"), object: nil)

                }
                else{
                    //error occurred
                    let alert = UIAlertController(title: "Log In Error", message: "We were unable to log you in.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dimiss", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
