//
//  User.swift
//  Wardah
//
//  Created by Dania on 6/12/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import SwiftyJSON


class AppUser: BaseModel {
    // MARK: Keys
    private let kUserFirstNameKey = "firstName"
    private let kUserLastNameKey = "lastName"
    private let KhomeIdKey = "homeId"
    private let KlanguagesKey = "languages"
    // MARK: Properties
    public var UID:String?
    public var firstName: String?
    public var lastName: String?
    public var email: String?
    public var token: String?
    public var fullName:String?
    public var homeId:String?
    public var languages:[Language]?
    public var views:[View]?
    
    // MARK: User initializer
    public override init(){
        super.init()
    }
    
    public required init(json: JSON) {
        super.init(json: json)
      
      self.UID = json["id"].string
      self.homeId = json[KhomeIdKey].string
        if let array = json[KlanguagesKey].array{
            self.languages = array.map{Language(json:$0)}
        }
        if let array = json["views"].array{
            self.views = array.map{View(json:$0)}
        }
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        // first name
        dictionary["id"] = self.UID
        dictionary[KhomeIdKey] = self.homeId
        dictionary[KlanguagesKey] = self.languages?.map{$0.dictionaryRepresentation()}
        if let array = self.views{
            dictionary["views"] = array.map{$0.dictionaryRepresentation()}
        }
        return dictionary
    }
    
}


