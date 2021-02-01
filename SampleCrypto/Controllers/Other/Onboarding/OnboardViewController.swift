//
//  OnboardViewController.swift
//  SampleCrypto
//
//  Created by Administrator on 1/31/21.
//

import AVKit
import FirebaseAuth
import UIKit

class OnboardViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    var videoPlayer:AVQueuePlayer?
    var videoPlayerLayer:AVPlayerLayer?
    var videoLooper:AVPlayerLooper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleModalDismissed),
                                                   name: NSNotification.Name(rawValue: "loginSuccess"),
                                                   object: nil)

        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Setup video in background
        setUpVideo()
    }
    
    @objc private func handleModalDismissed(){
        if Auth.auth().currentUser != nil{
            self.dismiss(animated: true, completion: nil)
        }
    }

    
    private func setUpElements(){
        
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }
    
    private func setUpVideo(){
        //Get path to resource in bundle & create url
        let bundlePath = Bundle.main.path(forResource: "bitcoin", ofType: "mp4")
        
        guard let path = bundlePath else{
            return
        }
        let url = URL(fileURLWithPath: path)
        
        //Create video player item
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        //Create player
        videoPlayer = AVQueuePlayer(playerItem: item)
        //Create layer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        //Adjust size & frame
        videoPlayerLayer?.frame = CGRect(x: 0,
                                         y: 0,
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.height)
        
        videoPlayerLayer?.videoGravity = .resizeAspectFill
        
        videoLooper = AVPlayerLooper(player: videoPlayer!, templateItem: item)
        
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        //Display and play
        videoPlayer?.playImmediately(atRate: 0.3)
        videoPlayer?.actionAtItemEnd = .none
    }
   
}
