//
//  PublicUserData.swift
//  On the Map
//
//  Created by nekki t on 2015/12/31.
//  Copyright © 2015年 next3. All rights reserved.
//

import Foundation
struct PublicUserData {
    var key: String?
    var firstName: String?
    var lastName: String?
    var location: String?
    var nickname: String?
    
    init(){}
    init(dictionary: [String: AnyObject]) {
        if let keyString = dictionary[DictionaryKey.Key] as? String {
            key = keyString
        }
        if let firstNameStr = dictionary[DictionaryKey.FirstName] as? String {
            firstName = firstNameStr
        }
        if let lastNameStr = dictionary[DictionaryKey.LastName] as? String {
            lastName = lastNameStr
        }
        
        if let locationString = dictionary[DictionaryKey.Location] as? String {
            location = locationString
        }
        if let nicknameString = dictionary[DictionaryKey.Nickname] as? String {
            nickname = nicknameString
        }
    }
    
    struct DictionaryKey {
        static let User = "user"
        static let Key = "key"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let Location = "location"
        static let Nickname = "nickname"
    }
    
}