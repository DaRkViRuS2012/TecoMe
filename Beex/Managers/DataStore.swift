//
//  DataStore.swift
//  
//
//  Created by AlphaApps on 14/11/16.
//  Copyright © 2016 BrainSocket. All rights reserved.
//

import SwiftyJSON

/**This class handle all data needed by view controllers and other app classes
 
 It deals with:
 - Userdefault for read/write cached data
 - Any other data sources e.g social provider, contacts manager, etc..
 **Usag:**
 - to write something to chach add constant key and a computed property accessors (set,get) and use the according method  (save,load)
 */
class DataStore :NSObject {
    
    //MARK: Cache keys
    private let CACHE_KEY_USER = "user"
    private let CACHE_KEY_CATEGORIES = "categories"
    private let CACHE_KEY_SHOW_COMMAND = "showCommand"
    //MARK: Temp data holders
    //keep reference to the written value in another private property just to prevent reading from cache each time you use this var
    private var _me:AppUser?
    private var _show:Bool?
//    private var _categories: [Category] = []
    
    // user loggedin flag
    var isLoggedin: Bool {
        if let token = me?.UID {
            return true
        }
        return false
    }

    // MARK: Cached data
    public var me:AppUser?{
        set {
            _me = newValue
            saveBaseModelObject(object: _me, withKey: CACHE_KEY_USER)
            NotificationCenter.default.post(name: .notificationUserChanged, object: nil)
        }
        get {
            if (_me == nil) {
                _me = loadBaseModelObjectForKey(key: CACHE_KEY_USER)
            }
            return _me
        }
    }
    
    
    public var showCommands:Bool{
        set {
            _show = newValue
            saveBoolWithKey(boolToStore: _show!, key: CACHE_KEY_SHOW_COMMAND)
        }
        get {
            if let value = loadBoolForKey(key: CACHE_KEY_SHOW_COMMAND){
                return value
            }
            return true
        }
    }
    
   
    //MARK: Singelton
    public static var shared: DataStore = DataStore()
    
    private override init(){
        super.init()
    }
   
    //MARK: Cache Utils
    public func saveBaseModelArray(array: [BaseModel] , withKey key:String){
        let data : [[String:Any]] = array.map{$0.dictionaryRepresentation()}
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public func loadBaseModelArrayForKey<T:BaseModel>(key: String)->[T]{
        var result : [T] = []
        if let arr = UserDefaults.standard.array(forKey: key) as? [[String: Any]]
        {
            result = arr.map{T(json: JSON($0))}
        }
        return result
    }
    
    public func saveBaseModelObject<T:BaseModel>(object:T?, withKey key:String)
    {
        UserDefaults.standard.set(object?.dictionaryRepresentation(), forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public func loadBaseModelObjectForKey<T:BaseModel>(key:String) -> T?
    {
        if let object = UserDefaults.standard.object(forKey: key)
        {
            return T(json: JSON(object))
        }
        return nil
    }
    
    public func loadStringForKey(key:String) -> String?{
        let storedString = UserDefaults.standard.object(forKey: key) as? String
        return storedString;
    }
    
    public func saveStringWithKey(stringToStore: String, key: String){
        UserDefaults.standard.set(stringToStore, forKey: key);
        UserDefaults.standard.synchronize();
    }
    
    public func loadBoolForKey(key:String) -> Bool?{
        let storedString = UserDefaults.standard.object(forKey: key) as? Bool
        return storedString;
    }
    
    public func saveBoolWithKey(boolToStore: Bool, key: String){
        UserDefaults.standard.set(boolToStore, forKey: key);
        UserDefaults.standard.synchronize();
    }
    
    private func loadIntForKey(key:String) -> Int{
        let storedInt = UserDefaults.standard.object(forKey: key) as? Int ?? 0
        return storedInt;
    }
    
    private func saveIntWithKey(intToStore: Int, key: String){
        UserDefaults.standard.set(intToStore, forKey: key);
        UserDefaults.standard.synchronize();
    }
    
    public func clearCache()
    {
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }

    public func saveUser(notify: Bool) {
        saveBaseModelObject(object: _me, withKey: CACHE_KEY_USER)
        if notify {
            NotificationCenter.default.post(name: .notificationUserChanged, object: nil)
        }
    }
    
    public func logout() {
        clearCache()
        me = nil
        

    }
}





