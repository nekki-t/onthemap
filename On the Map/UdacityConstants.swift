//
//  UdacityConstants.swift
//  On the Map
//
//  Created by nekki t on 2015/12/20.
//  Copyright © 2015年 next3. All rights reserved.
//

extension UdacityClient {
    // MARK: Constants
    struct Constants{
        // MARK: URLs
        static let AuthenticationURL : String = "https://www.udacity.com/api/session"
        static let PublicUserDataURL : String = "https://www.udacity.com/api/users/"
        static let SignUpURL : String = "https://www.udacity.com/account/auth#!/signin"

    }
    
    
    struct Methods{
        // MARK: Authentication
        
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        
        // MARK: Authorization
        static let Account = "account"
        static let Key = "key"
        static let ObjectId = "objectId"
        
    }
    
    struct ParseAccessInfo {
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let URLforStudentLocations = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    
}
