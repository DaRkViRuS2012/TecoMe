//
//  Languge.swift
//  BeeX
//
//  Created by Nour  on 4/10/18.
//  Copyright © 2018 NourAraar. All rights reserved.
//

import Foundation
import SwiftyJSON

class Language:BaseModel{
    
    private let kCodeKey = "code"
    private let kTitleKey = "title"
    
    
    // MARK: Properties
    public var code:String?
    public var title: String?
    
 
    // MARK: User initializer
    public override init(){
        super.init()
    }
    
    public required init(json: JSON) {
        super.init(json: json)
        
        self.code = json[kCodeKey].string
        self.title = json[kTitleKey].string
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = super.dictionaryRepresentation()
        // first name
        dictionary[kTitleKey] = self.title
        dictionary[kCodeKey] = self.code
        return dictionary
    }
    
    
    
    
}
