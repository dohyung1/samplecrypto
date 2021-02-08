//
//  ViewController.swift
//  SampleCrypto
//
//  Created by Administrator on 1/31/21.
//

import FBSDKLoginKit
import FirebaseAuth
import ShimmerSwift
import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapDM))
        

        let shimmerView = ShimmeringView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
        view.addSubview(shimmerView)
        shimmerView.center = view.center

        //Content View
        let button = UIButton(frame: shimmerView.bounds)
        button.backgroundColor = .systemBlue
        button.setTitle("Welcome. Sign out?", for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        shimmerView.contentView = button

        //Start/Stop animating
        shimmerView.isShimmering = true
        shimmerView.shimmerDirection = .right
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleNotAuthenticated()
    }
    
    @objc private func didTapDM(){
        let vc = DMViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapButton(){
        do{
            try Auth.auth().signOut()
            handleNotAuthenticated()
        }
        catch let signoutError as NSError{
            print(signoutError)
        }
        //Log out facebook
        FBSDKLoginKit.LoginManager().logOut()
        
    }
    
    private func handleNotAuthenticated(){
        //Check Auth Status
        if Auth.auth().currentUser == nil{
            //Show Onboarding if first time
            let didUserOnboard = UserDefaults.standard.bool(forKey: "user_onboarded")
            
            if didUserOnboard{
                //TODO: Show login if not first time
                guard let vc = storyboard?.instantiateViewController(identifier: "login") as? LoginViewController else{
                    print("failed to get login from storyboard")
                    return
                }
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                nav.modalTransitionStyle = .crossDissolve
                present(nav, animated: true)
                
            }
            else{
                //Show Onboarding if first time
                guard let onboardVC = storyboard?.instantiateViewController(identifier: "onboard") as? OnboardViewController else{
                    print("failed to get onboard from storyboard")
                    return
                }
                let nav = UINavigationController(rootViewController: onboardVC)
                nav.modalPresentationStyle = .fullScreen
                nav.modalTransitionStyle = .crossDissolve
                present(nav, animated: true)
            }
        }
    }
}
