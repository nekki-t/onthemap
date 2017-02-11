//
//  Student.swift
//  On the Map
//
//  Created by nekki t on 2015/12/27.
//  Copyright © 2015年 next3. All rights reserved.
//

import Foundation
import MapKit
struct StudentInformation {
    var createdAt: String?
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mapString: String?
    var mediaURL: String?
    var objectId: String?
    var uniqueKey: String?
    var updatedAt: String?
    
    static var StudentInformationArr:[StudentInformation]?
        
    
    init(){}
    init(dictionary: [String: AnyObject]) {
        if let createdAtDate = dictionary[DictionaryKey.CreatedAt] as? String {
            createdAt = createdAtDate
        }
        if let firstNameStr = dictionary[DictionaryKey.FirstName] as? String {
            firstName = firstNameStr
        }
        if let lastNameStr = dictionary[DictionaryKey.LastName] as? String {
            lastName = lastNameStr
        }
        if let latitudeDbl = dictionary[DictionaryKey.Latitude] as? Double {
            latitude = latitudeDbl
        }
        if let longitudeDbl = dictionary[DictionaryKey.Longitude] as? Double {
            longitude = longitudeDbl
        }
        if let mapStringStr = dictionary[DictionaryKey.MapString] as? String {
            mapString = mapStringStr
        }
        if let mediaURLStr = dictionary[DictionaryKey.MediaURL] as? String {
            mediaURL = mediaURLStr
        }
        if let objectIdStr = dictionary[DictionaryKey.ObjectId] as? String {
            objectId = objectIdStr
        }
        if let uniqueKeyStr = dictionary[DictionaryKey.UniqueKey] as? String {
            uniqueKey = uniqueKeyStr
        }
        if let updatedAtDate = dictionary[DictionaryKey.UpdatedAt] as? String {
            updatedAt = updatedAtDate
        }
        
    }
    
    struct DictionaryKey {
        static let Results = "results"
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
    }
    
    // From JsonResults to Array
    static func studentInformationFromResults (results: [[String: AnyObject]]){
        
        var studentInformationArr = [StudentInformation]()
        for child in results {
            
            studentInformationArr.append(StudentInformation(dictionary: child))
        }
        
        StudentInformation.StudentInformationArr = studentInformationArr
    }
}
