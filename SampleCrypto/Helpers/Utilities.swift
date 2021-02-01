//
//  Utilities.swift
//  SampleCrypto
//
//  Created by Administrator on 1/31/21.
//

import Foundation
import UIKit

class Utilities{
    
    static func styleTextField(_ textfield: UITextField){
        
        //Create bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0,
                                  y: textfield.frame.height - 2,
                                  width: textfield.frame.width - 20,
                                  height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255,
                                                  green: 173/255,
                                                  blue: 99/255,
                                                  alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        //Add line to text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleFilledButton(_ button: UIButton){
        
        //Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 48/255,
                                              green: 173/255,
                                              blue: 99/255,
                                              alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button: UIButton){
        
        //Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.label
        button.setTitleColor(.white, for: .normal)
    }
    
    static func isPasswordValid(_ password:String) -> Bool{
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
}
