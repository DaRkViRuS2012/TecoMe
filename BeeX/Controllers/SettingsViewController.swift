//
//  SettingsViewController.swift
//  BeeX
//
//  Created by Nour  on 4/10/18.
//  Copyright © 2018 NourAraar. All rights reserved.
//

import UIKit
import DropDown

class SettingsViewController: AbstractController {

    @IBOutlet weak var serverTextFeild: XUITextField!
    @IBOutlet weak var portTextFeild: XUITextField!
    
    @IBOutlet weak var languagesButton: UIButton!
    
    
    // city dropDown
    var languageDropDown = DropDown()
    
    var languages:[Language] = []
    var languagesList:[String] = []
    var selectedLang:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.showNavBackButton = true
        self.showLogoutNavCloseButton = true
        self.setNavBarTitle(title: "Settings".localized)
        self.languagesButton.setTitle(AppConfig.langCode, for: .normal)
        selectedLang = AppConfig.langCode
        getlanguages()
        prepareCityDropDown()
        
      
        self.serverTextFeild.text = AppConfig.server ?? ""
        self.portTextFeild.text = AppConfig.port ?? ""
      
        
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func save(_ sender: UIButton) {
        if let server = serverTextFeild.text,!server.isEmpty{
            AppConfig.server = server
        }else{
            self.showMessage(message: "please enter a server".localized, type: .error)
            return
        }
        
        
        if let port = portTextFeild.text,!port.isEmpty{
            AppConfig.port = port
        }else{
            self.showMessage(message: "please enter a port".localized, type: .error)
            return
        }
        
        AppConfig.langCode = selectedLang!
        self.showMessage(message: "Done".localized, type: .success)
        
    }
    @IBAction func selectLanguage(_ sender: UIButton) {
        toggleDropDown()
    }
    
    func toggleDropDown(){
        
        if languageDropDown.isHidden {
            languageDropDown.show()
        }else{
            languageDropDown.hide()
        }
        
    }
    func getlanguages(){
        
        if let langs = DataStore.shared.me?.languages{
            self.languages = langs
            self.languagesList = languages.map{$0.title!}
        }
        
    }
    
    
    
    func prepareCityDropDown(){
        languageDropDown.anchorView = languagesButton
        languageDropDown.dataSource = self.languagesList
        
        languageDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.languagesButton.setTitle(item, for: .normal)
            self.selectedLang = self.languages[index].code
        }
        
    }
   
    
}
