//
//  View.swift
//  Teco M.E.
//
//  Created by Nour  on 9/30/18.
//  Copyright © 2018 NourAraar. All rights reserved.
//

import Foundation
import SwiftyJSON
/*
 {"ip":"192.168.0.100","var":"salon","title":"salon view","username":"teco","password":"1234"}
 */
public class View:BaseModel{
    
    private let kIPKey = "ip"
    private let kTitleKey = "title"
    private let kvarKey = "var"
    private let kusernameKey = "username"
    private let KpasswordKey = "password"
    
    
    // MARK: Properties
    public var ip:String?
    public var title: String?
    public var varValue: String?
    public var username: String?
    public var password: String?
    
    // MARK: User initializer
    public override init(){
        super.init()
    }
    
    public required init(json: JSON) {
        super.init(json: json)
        
        self.ip = json[kIPKey].string
        self.title = json[kTitleKey].string
        self.varValue = json[kvarKey].string
        self.username = json[kusernameKey].string
        self.password = json[KpasswordKey].string
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        // first name
            dictionary[kIPKey] = self.ip
            dictionary[kTitleKey] = self.title
            dictionary[kvarKey] = self.varValue
            dictionary[kusernameKey] = self.username
            dictionary[KpasswordKey] = self.password
        return dictionary
    }
    
    
    
    
}

