//
//  String.swift
//  
//
//  Created by AlphaApps on 02/11/16.
//  Copyright © 2016 BrainSocket. All rights reserved.
//

import UIKit

extension String {
    
    /// Return count of chars
    var length: Int {
        return characters.count
    }
    
    /// Check if the string is a valid email
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    
    /// Check if the string is a valid Date
    func isValidDate() -> Bool {
        
        if let _ = DateHelper.getDateFromString(self){
            return true
        }
        
        if let _ = DateHelper.getBirthDateFromString(self){
            return true
        }
        
        
        if let _ = DateHelper.getDateFromISOString(self){
            return true
        }
        
        
        if let _ = DateHelper.getFormatedDateFromString(self){
        return true
        }
        
        return false
    }
    
    
    /// Check if the string is alphanumeric
    var isAlphanumeric: Bool {
        return self.range(of: "^[a-z A-Z]+$", options:String.CompareOptions.regularExpression) != nil
    }
    
    var isNumber: Bool {
        return self.range(of: "^[0-9]+$", options:String.CompareOptions.regularExpression) != nil
    }
    
    
    //validate PhoneNumber
    var isPhoneNumber: Bool {
        
        let charcter  = NSCharacterSet(charactersIn: "+0123456789").inverted
        var filtered:String!
        let inputString:NSArray = self.components(separatedBy: charcter) as NSArray
        filtered = inputString.componentsJoined(by: "")
        return  self == filtered && (self.hasPrefix("+") || self.hasPrefix("00"))
        
    }
    
    
    /// Localized current string key
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Localized text using string key
    public static func localized(_ key:String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    /// Remove spaces and new lines
    var trimed :String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /// Get label height for string
    func getLabelHeight(width: CGFloat, font: UIFont) -> CGFloat {
        let label = UILabel(frame: .zero)
        label.frame.size.width = width
        label.font = font
        label.numberOfLines = 0
        label.text = self
        label.sizeToFit()
        return label.frame.size.height
    }
    
    
    
    // bsae 64
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
