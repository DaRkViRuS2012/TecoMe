//
//  UITextField.swift
//  Wardah
//
//  Created by Molham Mahmoud on 6/20/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    func appStyle() {
        self.borderStyle = .none
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let padding = CGFloat(16.0)
        let border = CALayer()
        let Vheight = CGFloat(1.0)

        border.borderColor = AppColors.primary.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - Vheight , width:  screenWidth - 2 * padding, height: Vheight)
        border.borderWidth = Vheight
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.clear
        self.font = AppFonts.big
        self.textAlignment = .left
        if (AppConfig.currentLanguage == .arabic) {
            self.textAlignment = .right
        }
    }
    
    func appStyle2() {
        self.borderStyle = .none
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let padding = CGFloat(16.0)
        let border = CALayer()
        let height = CGFloat(1.0)
        
        border.borderColor = AppColors.gray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - height, width:  screenWidth - 2 * padding, height: height)
        border.borderWidth = height
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.clear
        self.font = AppFonts.big
        self.textAlignment = .left
        if (AppConfig.currentLanguage == .arabic) {
            self.textAlignment = .right
        }
    }

    
    
    func searchBarStyle() {
        self.borderStyle = .none
        self.backgroundColor = UIColor.clear
        self.font = AppFonts.big
        self.textAlignment = .left
        if (AppConfig.currentLanguage == .arabic) {
            self.textAlignment = .right
        }
    }

    func appStyle(padding: Int) {
        self.borderStyle = .none
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let border = CALayer()
        let height = CGFloat(1.0)
        border.borderColor = AppColors.gray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - height , width:  screenWidth - 2 * CGFloat(padding), height: height)
        border.borderWidth = height
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.clear
        self.font = AppFonts.xSmall
        self.textAlignment = .left
        if (AppConfig.currentLanguage == .arabic) {
            self.textAlignment = .right
        }
    }
    
    
    
    func addIconButton(image:String){
        let button = UIButton(type: .custom)
        var img = UIImage(named: image)
        img = img?.imageFlippedForRightToLeftLayoutDirection()
        button.setImage(img , for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        if (AppConfig.currentLanguage == .arabic) {
            button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -16)
        }else{
            button.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)
        }
  
        
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 30), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        
        
        self.rightView = button
        self.rightViewMode = .always
        
    }
    
    
    func removeIconButton(){
        self.rightView = nil
        self.leftView = nil
    }
    
    func addLeftIconButton(image:String){
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: image), for: .normal)
        
//        if (AppConfig.currentLanguage == .arabic) {
//            button.imageEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0)
//        }else{
//            button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -16)
//        }
        button.frame = CGRect(x: 0, y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        
        self.leftView = button
        self.leftViewMode = .always
    }
    
    
    func showOrHideText(){
        self.isSecureTextEntry = !isSecureTextEntry
    }
    
    func showActivityIndicator(show:Bool){
    
        if show{
            self.rightView = nil
            let activityIndicator:UIActivityIndicatorView =  UIActivityIndicatorView()
            activityIndicator.activityIndicatorViewStyle = .gray
            if (AppConfig.currentLanguage == .arabic) {
                
                activityIndicator.frame = CGRect(x: 16 , y: 0, width: 24, height: 24)
            }else{
                activityIndicator.frame = CGRect(x: -16 , y: 0, width: 24, height: 24)
            }
 
            
            self.rightView?.backgroundColor = .red
            self.rightView = activityIndicator
            self.rightViewMode = .always
          //  activityIndicator.center = CGPoint(x: (self.rightView?.center.x)! - 16, y: (self.rightView?.center.y)!)
            activityIndicator.startAnimating()
         
        
        }else{
        
            self.rightView = nil
        
        }
        
        
    
    }
    
  
    
    
}




extension UITextField: UITextFieldDelegate{
    func addToolBar(){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        
        let doneButton = UIBarButtonItem(image: #imageLiteral(resourceName: "down_arrow"), style: .done, target: self, action: #selector(UITextField.cancelPressed))
        //let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UITextField.cancelPressed))
       // let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        self.delegate = self
        self.inputAccessoryView = toolBar
    }
    func donePressed(){
        self.superview?.endEditing(true)
    }
    @objc func cancelPressed(){
        self.superview?.endEditing(true)
    }
    
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        addToolBar()
    }
}
