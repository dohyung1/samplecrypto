//
//  ViewController.swift
//  SampleCrypto
//
//  Created by Administrator on 1/31/21.
//

import RAMAnimatedTabBarController
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
        button.setTitle("Unlock", for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        shimmerView.contentView = button

        //Start/Stop animating
        shimmerView.isShimmering = true
        shimmerView.shimmerDirection = .right
        
    }

    @objc func didTapButton(){
        let tabBarVC = CustomTabBarController()
        present(tabBarVC, animated: true)
    }

}

class CustomTabBarController : RAMAnimatedTabBarController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure(){
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        let vc3 = UIViewController()
        let vc4 = UIViewController()
        
        vc1.view.backgroundColor = .systemGreen
        vc2.view.backgroundColor = .systemBlue
        vc3.view.backgroundColor = .systemOrange
        vc4.view.backgroundColor = .systemPink
        
        vc1.tabBarItem = RAMAnimatedTabBarItem(title: "",
                                               image: UIImage(systemName: "house"),
                                               tag : 1)
        
        (vc1.tabBarItem as? RAMAnimatedTabBarItem)?.animation = RAMBounceAnimation()
        
        vc2.tabBarItem = RAMAnimatedTabBarItem(title: "",
                                               image: UIImage(systemName: "bitcoinsign.circle"),
                                               tag : 1)
        
        (vc2.tabBarItem as? RAMAnimatedTabBarItem)?.animation = RAMBounceAnimation()
        
        vc3.tabBarItem = RAMAnimatedTabBarItem(title: "",
                                               image: UIImage(systemName: "bell"),
                                               tag : 1)
        
        (vc3.tabBarItem as? RAMAnimatedTabBarItem)?.animation = RAMBounceAnimation()
        
        vc4.tabBarItem = RAMAnimatedTabBarItem(title: "",
                                               image: UIImage(systemName: "gear"),
                                               tag : 1)
        
        (vc4.tabBarItem as? RAMAnimatedTabBarItem)?.animation = RAMBounceAnimation()
        
        
        setViewControllers([vc1,vc2,vc3,vc4], animated: false)
    }
}

