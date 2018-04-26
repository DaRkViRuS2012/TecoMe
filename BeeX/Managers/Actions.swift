//
//  Actions.swift
//  Wardah
//
//  Created by Dania on 7/5/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import Foundation
import UIKit
/**
Repeated and generic actions to be excuted from any context of the app such as show alert
 */
class Action: NSObject {
    class func execute() {
    }
 
}

class ActionLogout:Action
{
    override class func execute() {
        let cancelButton = UIAlertAction(title: "CANCEL".localized, style: .cancel, handler: nil)
        let okButton = UIAlertAction(title: "Ok".localized, style: .default, handler: {
            (action) in
            //clear user
            DataStore.shared.logout()
            
            ActionShowStart.execute()
        })
        let alert = UIAlertController(title: "".localized, message: "you are about to logout!".localized, preferredStyle: .alert)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        if let controller = UIApplication.visibleViewController()
        {
            controller.present(alert, animated: true, completion: nil)
        }
    }
}

class ActionShowStart: Action {
    override class func execute() {
        UIApplication.appWindow().rootViewController = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: StartViewController.className)
    }
}
