//
//  ProfileViewController.swift
//  SampleCrypto
//
//  Created by Administrator on 1/31/21.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .systemRed
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out",
                                            style: .destructive,
                                            handler: { [weak self] _ in
                                                
                                                guard let strongSelf = self else{
                                                    return
                                                }
                                                
                                                //Log out facebook
                                                FBSDKLoginKit.LoginManager().logOut()
                                                
                                                do{
                                                    try Auth.auth().signOut()
                                                    
                                                    guard let loginVC = strongSelf.storyboard?.instantiateViewController(identifier: "login") as? LoginViewController else{
                                                        print("failed to get login from storyboard")
                                                        return
                                                    }
                                                    let nav = UINavigationController(rootViewController: loginVC)
                                                    nav.modalPresentationStyle = .fullScreen
                                                    nav.modalTransitionStyle = .crossDissolve
                                                    strongSelf.present(nav, animated: true)
                                                    
                                                }
                                                catch{
                                                    print("Failed to log out.")
                                                }
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
        
    }
}
