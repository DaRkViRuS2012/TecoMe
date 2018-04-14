//
//  Languge.swift
//  BeeX
//
//  Created by Nour  on 4/10/18.
//  Copyright © 2018 NourAraar. All rights reserved.
//

import Foundation
import SwiftyJSON

class Command:BaseModel{
    
    private let kCodeKey = "command"
    private let kTitleKey = "title"
    
    
    // MARK: Properties
    public var command:String?
    public var title: String?
    
    
    // MARK: User initializer
    public override init(){
        super.init()
    }
    
    public required init(json: JSON) {
        super.init(json: json)
        
        self.command = json[kCodeKey].string
        self.title = json[kTitleKey].string
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        // first name
        dictionary[kTitleKey] = self.title
        dictionary[kCodeKey] = self.command
        return dictionary
    }
    
    
    
    
}

