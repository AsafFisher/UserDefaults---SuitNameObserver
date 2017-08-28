//
//  UserDefaultsSuitNameObserver.swift
//  CountDown
//
//  Created by Asaf Fisher on 8/28/17.
//  Copyright © 2017 Asaf Fisher. All rights reserved.
//
// This project has some really bad habbits and is not optimized. Untill apple will deside to have some decent sane. I tends to use it.
//
import Foundation
class SuitNameObserver: NSObject {
    //UserDefault object.
    let userDefaults:UserDefaults
    
    //Suit name
    var suitName:String
    
    //Data returned from userdefaults.
    var data:Any?
    
    //bool var for controlling the infinite loop.
    var keepRunning = false
    
    
    //Init the object with a suitname. Important!
    required init(suitName:String) {
        self.suitName = suitName
        userDefaults = UserDefaults(suiteName: suitName)!
    }
    
    
    //Call this async method with a key value of the observed object in the userdefaults
    //It returns a callback eachtime a change has been make for the specific value with an Any object result.
    //The type that is stored is needed in order to work properly for example, if Int is stored, type should be Int.self.
    func bindUD<T:Equatable>(key:String, type:T.Type, callback: @escaping (_ result: Any?)->()){
        //initialize
        keepRunning = true
        
        //Start background job.
        DispatchQueue.global(qos: .background).async {
            //Boolean to know if its the first itiration.
            var firstTime = true
            
            //While your not told to stop.
            while self.keepRunning{
                
                //Gets the data for the key.
                if let data = self.userDefaults.object(forKey: key) as Any?{
                    
                    //If its first time and data in userdefaults is not nil it will save the data
                    if firstTime {
                        self.data = data
                        firstTime = false
                        continue
                    }
                    //If the current data is nil and userdefaults was set to a non-nil value return a callback with the object and save the recived data to self.data
                    if self.data == nil{
                        self.data = data
                        callback(data)
                        continue
                    }
                    
                    //Check if the data was already delivered, because userdefaults saves value and is not being reset in the apps life cycle.
                    if !self.isEqual(type: type, a: self.data, b: data)! {
                        self.data = data
                        callback(data)
                        continue
                    }
                    
                }else{
                    //If the new data that was recived is nil, set the current data to nil and return a nil callback.
                    if self.data != nil{
                        self.data = nil
                        callback(nil)
                    }
                }
                
            }
        }
        
        
    }
    //Check if two objects are the same.
    func isEqual<T: Equatable>(type: T.Type, a: Any?, b: Any?) -> Bool? {
        guard let a = a as? T, let b = b as? T else { return nil }
        
        return a == b
    }
    
    
}
