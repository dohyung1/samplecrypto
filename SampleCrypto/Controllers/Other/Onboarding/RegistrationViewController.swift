//
//  RegistrationViewController.swift
//  SampleCrypto
//
//  Created by Administrator on 1/31/21.
//

import FirebaseAuth
import Firebase
import UIKit
import JGProgressHUD

class RegistrationViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
 
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
    }
    
    private func setUpElements(){
        
        //Hide error label
        errorLabel.alpha = 0
        
        //Style
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
    }
    
    //Check the fields and validate that the data is correct. If all is good, returns nil. Otherwise, returns error message
    private func validateFields() -> String?{
        
        //Check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields."
        }
        
        //Check if pw is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false{
            // Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        return nil
    }
    
    private func showError(_ message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }

    @IBAction func signUpTapped(_ sender: Any) {
        
        //Validate the fields
        let error = validateFields()
        if error != nil{
            //There was an error in fields, show error message
            showError(error!)
        }
        else{
            
            // Create cleaned version of user data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            spinner.show(in: view)
            DatabaseManager.shared.userExists(with: email) { [weak self]exists in
                guard let strongSelf = self else{
                    return
                }
                
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()
                }
                
                guard !exists else{
                    strongSelf.showError("User account for this email address already exists.")
                    return
                }
                
                //Create the user
                Auth.auth().createUser(withEmail: email, password: password) {results, error in
                    guard results != nil, error == nil else{
                        strongSelf.showError("Error creating user.")
                        return
                    }
                    strongSelf.spinner.dismiss()
                    
                    DatabaseManager.shared.insertUser(with: User(firstName: firstName,lastName: lastName, emailAddress: email),
                                                      completion: {success in                    
                                                        if success{
                                                            //void
                                                        }
                                                      })
                    
                    strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                    if !UserDefaults.standard.bool(forKey: "user_onboarded"){
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginSuccess") , object: nil)
                    }
                }
            }
        }
    }
}
