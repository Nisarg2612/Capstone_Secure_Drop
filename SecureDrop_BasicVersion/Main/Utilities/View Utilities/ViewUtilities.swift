//
//  ViewController.swift
//  SecureDrop_BasicVersion
//
//  Created by Suman Chatla on 9/22/22.
//

import Foundation
import UIKit

class CustomUtilities {
    
    static func styleTextField(_ textfield:UITextField) {
        
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2,width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255,green: 173/255, blue: 99/255, alpha:1).cgColor
        // remove border on textfield
        textfield .borderStyle = .none
        
        // add the line to the text field
        textfield.layer.addSublayer(bottomLine)
    }

    static func styleFilledButton(_ button:UIButton) {
        
        //Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
        button.layer.cornerRadius = 20
        button.tintColor = UIColor.white
    }

    static func styleHollowButton(_ button:UIButton) {
        
        //Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.backgroundColor = UIColor.black.cgColor
        button.layer.cornerRadius = 20
        button.tintColor = UIColor.black
    }
    static func isEmailValid(_ email: String) -> Bool {
        let emailTest = NSPredicate(format: "SELF MATCHES %@","[.\\w]+@[a-z]+\\.com")
        return emailTest.evaluate(with: email)
        
    }
    static func isPasswordValid(_ password : String) -> Bool{
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@","^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}")
//        passwordTest.evaluate(with: password)
        return true
    }
}

