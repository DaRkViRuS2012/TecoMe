//
//  Constants.swift
//  Wardah
//
//  Created by Dania on 12/25/16.
//  Copyright © 2016 . All rights reserved.
//
import UIKit


// MARK: Application configuration
struct AppConfig {
    
    // domain
    
    static let useLiveAPI: Bool = false
    static let useCurrentLocation: Bool = false

    // validation
    static let passwordLength = 6
    
    
    
    // current application language
    static var currentLanguage:AppLanguage {
        let locale = NSLocale.current.languageCode
        if (locale == "ar") {
            return .arabic
        }
        return .english
    }
    
    static var langCode:String{
        
        set{
            let value = newValue
            DataStore.shared.saveStringWithKey(stringToStore: value, key: "langCode")
        }
        get{
        if let code = DataStore.shared.loadStringForKey(key: "langCode"){
            return code
        }
            return "en"
        }
    }
    
    static var server:String?{
        
        set{
            let value = newValue
            DataStore.shared.saveStringWithKey(stringToStore: value!, key: "server")
        }
        get{
            if let code = DataStore.shared.loadStringForKey(key: "server"){
                return code
            }
            return nil
        }
    }
    
    
    static var port:String?{
        
        set{
            let value = newValue
            DataStore.shared.saveStringWithKey(stringToStore: value!, key: "port")
        }
        get{
            if let code = DataStore.shared.loadStringForKey(key: "port"){
                return code
            }
            return nil
        }
    }
    
    
    /// Set navigation bar style, text and color
    static func setNavigationStyle() {
        // set text title attributes
        let attrs = [NSAttributedStringKey.foregroundColor : UIColor.white ,
                     NSAttributedStringKey.font : AppFonts.big]
        UINavigationBar.appearance().titleTextAttributes = attrs
        // set background color
        UINavigationBar.appearance().barTintColor = AppColors.navColor
        UINavigationBar.appearance().isTranslucent = false
        // remove under line
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }
    
    static func setTabBarStyle(){
    
        UITabBar.appearance().tintColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    }
    
    static func getwebSize()->webSize{
        
        if ScreenSize.isIphone{
            return webSize.medium
        }
        if ScreenSize.isIpad{
            return webSize.larg
        }
        if ScreenSize.isBigScreen{
            return webSize.larg
        }
        return webSize.xlarg
    }
}


// MARK: Notifications
extension Notification.Name {
    static let notificationLocationChanged = Notification.Name("NotificationLocationChanged")
    static let notificationUserChanged = Notification.Name("NotificationUserChanged")
    static let notificationFilterOpened = Notification.Name("NotificationFilterOpened")
    static let notificationFilterClosed = Notification.Name("NotificationFilterClosed")
    static let notificationRefreshStories = Notification.Name("NotificationRefreshStories")
    static let notificationRefreshCart = Notification.Name("NotificationRefreshCart")
}

// MARK: Screen size
enum ScreenSize {
    static let isSmallScreen =  UIScreen.main.bounds.height <= 568 // iphone 4/5
    static let isMidScreen =  UIScreen.main.bounds.height <= 667 // iPhone 6 & 7
    static let isBigScreen =  UIScreen.main.bounds.height >= 736 // iphone 6Plus/7Plus
    static let isIphone = UIDevice.current.userInterfaceIdiom == .phone
    static let isIpad = UIDevice.current.userInterfaceIdiom == .pad
}

enum webSize:String{
    case small = "S"
    case larg = "L"
    case xlarg = "X"
    case medium = "M"
}



enum ScreenSizeRatio{

    static let smallRatio = Double(UIScreen.main.bounds.height / 1334 ) * 2.0
    static let largRatio =  Double(UIScreen.main.bounds.height / 1334 )
}

// MARK: Application language
enum AppLanguage{
    case english
    case arabic
    
    var langCode:String {
        switch self {
        case .english:
            return "en"
        case .arabic:
            return "ar"
        }
    }
}







