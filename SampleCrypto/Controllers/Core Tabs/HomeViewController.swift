//
//  ViewController.swift
//  SampleCrypto
//
//  Created by Administrator on 1/31/21.
//

import FirebaseAuth
import ShimmerSwift
import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @objc private func didTapButton(){
        do{
            try Auth.auth().signOut()
            handleNotAuthenticated()
        }
        catch let signoutError as NSError{
            print(signoutError)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleNotAuthenticated()
    }
    
    private func handleNotAuthenticated(){
        //Check Auth Status
        if Auth.auth().currentUser == nil{
            //Show log in
            guard let onboardVC = storyboard?.instantiateViewController(identifier: "onboard") as? OnboardViewController else{
                print("failed to get onboard from storyboard")
                return
            }
            onboardVC.modalPresentationStyle = .fullScreen
            present(onboardVC, animated: true)
        }
        
    }

}
