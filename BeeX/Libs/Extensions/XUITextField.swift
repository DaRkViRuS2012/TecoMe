//
//  XUITextField.swift
//  Wardah
//
//  Created by Nour  on 12/22/17.
//  Copyright © 2017 AlphaApps. All rights reserved.
//

import Foundation
import UIKit


private var kAssociationKeyMaxLength: Int = 0


class XUITextField:UITextField{
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        //self.appStyle2()
        self.placeholder = self.placeholder?.localized
        self.font = AppFonts.normal
        self.perform(#selector(setStyle), with: nil, afterDelay: 0.3)
    }
    
     @objc func setStyle(){
        self.appStyle2()
    }
    
    
    
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        self.perform(#selector(setStyle), with: nil, afterDelay: 0.3)
        }
    //
    //    override func textRect(forBounds bounds: CGRect) -> CGRect {
    //        return UIEdgeInsetsInsetRect(bounds,
    //                                     UIEdgeInsetsMake(0, 40, 0, 15))
    //    }
    //
    //    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    //        return UIEdgeInsetsInsetRect(bounds,
    //                                     UIEdgeInsetsMake(0, 40, 0, 15))
    //    }
    //
    //    override func editingRect(forBounds bounds: CGRect) -> CGRect {
    //        return UIEdgeInsetsInsetRect(bounds,
    //                                     UIEdgeInsetsMake(0, 40, 0, 15))
    //    }
}


class PasswordTextField:UITextField{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
     
        
        self.placeholder = self.placeholder?.localized
        self.font = AppFonts.normal
        self.addIconButton()
        self.perform(#selector(setStyle), with: nil, afterDelay: 0.3)
    }
    
    @objc func setStyle(){
        self.appStyle2()
    }
    
    func addIconButton(){
        
        self.addIconButton(image: "eyeIcon")
        let passwordTextFieldRightButton = self.rightView as! UIButton
        passwordTextFieldRightButton.addTarget(self, action: #selector(hideText), for: .touchUpInside)
    }
    
    @objc func hideText(){
        self.isSecureTextEntry = !self.isSecureTextEntry
    }
    
    
    
}




class CreditCardTextField:UITextField{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customize()
    }
    
    
    func customize(){
        self.appStyle()
       // self.font = AppFonts.xtraSmall
        
    }
    
    
    
    
    
    
    
}



extension String {
    func grouping(every groupSize: String.IndexDistance, with separator: Character) -> String {
        let cleanedUpCopy = replacingOccurrences(of: String(separator), with: "")
        return String(cleanedUpCopy.characters.enumerated().map() {
            $0.offset % groupSize == 0 ? [separator, $0.element] : [$0.element]
            }.joined().dropFirst())
    }
}

