//
//  UserDefaultsSuitNameObserver.swift
//  CountDown
//
//  Created by Asaf Fisher on 8/28/17.
//  Copyright © 2017 Asaf Fisher. All rights reserved.
//

import Foundation
class SuitNameObserver: NSObject {
    let userDefaults:UserDefaults
    var suitName:String
    var data:Any?
    var keepRunning = false
    
    init(suitName:String) {
        self.suitName = suitName
        userDefaults = UserDefaults(suiteName: suitName)!
    }
    
    
    func bindUD<T:Equatable>(key:String, type:T.Type, callback: @escaping (_ result: Any?)->()){
        keepRunning = true
        DispatchQueue.global(qos: .background).async {
            var firstTime = true
            while self.keepRunning{
                
                if let data = self.userDefaults.object(forKey: key) as Any?{
                    
                    if firstTime {
                        self.data = data
                        firstTime = false
                        continue
                    }
                    
                    if self.data == nil{
                        self.data = data
                        callback(data)
                        continue
                    }
                    
                    if !self.isEqual(type: type, a: self.data, b: data)! {
                        self.data = data
                        callback(data)
                        continue
                    }
                    
                }else{
                    if self.data != nil{
                        self.data = nil
                        callback(nil)
                    }
                }
                
            }
        }
        
        
    }
    
    func isEqual<T: Equatable>(type: T.Type, a: Any?, b: Any?) -> Bool? {
        guard let a = a as? T, let b = b as? T else { return nil }
        
        return a == b
    }
    
    
}
