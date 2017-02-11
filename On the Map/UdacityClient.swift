//
//  UdacityClient.swift
//  On the Map
//
//  Created by nekki t on 2015/12/20.
//  Copyright © 2015年 next3. All rights reserved.
//

import Foundation
import MapKit

class UdacityClient : NSObject {
   
    //MARK: - Variables
    /* Shard Session */
    var session: NSURLSession
    
    /* Authentication Data */
    var userID: Int?
    var facebookToken: String?
    

    /* Shared User and Student Data */
    var publicUserData: PublicUserData?
    var studentLocations:[StudentInformation]?
    
    var locationObjectId: String?
    
    //MARK: - Life Cycle
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //MARK: - Udacity API
    // Login by email & password
    func postToLogin(email: String!, password: String!, completionHandler: (success: Bool, error: String?) -> Void){
        
        let httpBodyString = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        sharedLoginProcedure(httpBodyString, isFacebookLogin: false, completionHandler: completionHandler)
    }
    // Login with facebook
    func postToLogin(facebookToken: String!, completionHandler: (success: Bool, error: String?) -> Void){
    
        let httpBodyString = "{\"facebook_mobile\": {\"access_token\": \"\(facebookToken)\"}}"
        self.facebookToken = facebookToken
        sharedLoginProcedure(httpBodyString, isFacebookLogin: true, completionHandler: completionHandler)
    }
    
    
    func sharedLoginProcedure(httpBodyString: String!, isFacebookLogin: Bool, completionHandler: (success: Bool, error: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityClient.Constants.AuthenticationURL)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = httpBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error == nil) else {
                completionHandler(success: false, error: "Login Failed (Request Failed: Network Error Occured)!")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    var failedMsg = ""
                    if isFacebookLogin {
                        failedMsg = "Your facebook account is denied to login"
                    } else {
                        failedMsg = "Invalid Email or Password"
                    }
                    completionHandler(success: false, error:"\(failedMsg) (Forbidden)!")
                    print("Your request returned an invalid response! Status Code: \(response.statusCode)!")
                } else if let response = response {
                    completionHandler(success: false, error:"Login Failed (Invalid Response)!")
                    print("Your request returned an invalid response! Response: \(response)!")
                    
                } else {
                    completionHandler(success: false, error:"Login Failed (No Response)!")
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                completionHandler(success: false, error:"Login Failed (No Data)!")
                return
            }
            
            UdacityClient.parseJSONWithCompletionHandler(data.subdataWithRange(NSMakeRange(5, data.length - 5))){
                JSONResult, error in
                if let _ = error {
                    completionHandler(success: false, error: "Login Failed(JSON Error)")
                } else {
                    if let student = JSONResult[UdacityClient.JSONResponseKeys.Account] as? [String: AnyObject] {
                        if let keyString = student[UdacityClient.JSONResponseKeys.Key] as? String {
                            self.userID = Int(keyString)
                            completionHandler(success: true, error: nil)
                        } else {
                            completionHandler(success: false, error: "Login Failed(couldn't find a student key in the server response!)")
                        }
                    } else {
                        completionHandler(success: false, error: "Login Failed(No Proper Response from Udacity Server)")
                    }
                }
            }
        }
        
        task.resume()
        
    }

    
    
    // Logout
    func deleteToLogout(completionHandler: (success: Bool, error: String?) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityClient.Constants.AuthenticationURL)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie:NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            let errorString = self.guardingForResponse("Logout", data: data, response: response, error: error)
            
            if errorString != nil {
                completionHandler(success: false, error: errorString)
                return
            }
            
            UdacityClient.parseJSONWithCompletionHandler(data!.subdataWithRange(NSMakeRange(5, data!.length - 5))){
                JSONResult, error in
                print(JSONResult)
                completionHandler(success: true, error: nil)
            }
        }
        task.resume()
    }
    
    
    // MARK: - Public User Data
    func getPublicUserData(completionHandler:(success: Bool, error: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityClient.Constants.PublicUserDataURL + "\(userID!)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            let errorString = self.guardingForResponse("Loading Public User Data Information", data: data, response: response, error: error)
            
            if errorString != nil {
                completionHandler(success: false, error: errorString)
                return
            }
            
            UdacityClient.parseJSONWithCompletionHandler(data!.subdataWithRange(NSMakeRange(5, data!.length - 5))){
                JSONResult, error in
                if let result = JSONResult[PublicUserData.DictionaryKey.User] as? [String: AnyObject] {
                    self.publicUserData = PublicUserData(dictionary: result)
                    completionHandler(success: true, error: nil)
                } else {
                    completionHandler(success: false, error: "Loading Student Information Failed (Invalid Parsed Data)!")
                }
               
            }
        }
        task.resume()
    }
    
    // MARK: - Parse API
    
    // For map and list
    func getStudentLoations(completionHandler:(success: Bool, error: String?) -> Void){
        let parameters = ["order": "-updatedAt", "limit":100]
        let request = getParseRequest("GET", parameters: parameters)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            let errorString = self.guardingForResponse("Loading Student Information", data: data, response: response, error: error)

            if errorString != nil {
                completionHandler(success: false, error: errorString)
                return
            }
            
            UdacityClient.parseJSONWithCompletionHandler(data!){
                JSONResult, error in
                if let results = JSONResult[StudentInformation.DictionaryKey.Results] as? [[String: AnyObject]]{
                    StudentInformation.studentInformationFromResults(results)
                    completionHandler(success: true, error: nil)
                    
                } else {
                    completionHandler(success: false, error: "Loading Student Information Failed (Invalid Parsed Data)!")
                }
            }
        
        }
        task.resume()
    }
    
    
    // Already posted?
    func postedObjectId(completionHandler:(success: Bool, error: String?) -> Void){
        let parameters = ["where": "{\"uniqueKey\":\"\(userID!)\"}"]
        let request = getParseRequest("GET", parameters: parameters)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            let errorString = self.guardingForResponse("Loading Current User Location Information", data: data, response: response, error: error)
            
            if errorString != nil {
                completionHandler(success: false, error: errorString)
                return
            }
            
            UdacityClient.parseJSONWithCompletionHandler(data!){
                JSONResult, error in
                if let results = JSONResult[StudentInformation.DictionaryKey.Results] as? [[String: AnyObject]]{
                    if results.count > 0 {
                        self.locationObjectId = String(results[0][UdacityClient.JSONResponseKeys.ObjectId]!)
                        completionHandler(success: true, error: nil)
                    } else {
                        completionHandler(success: false, error: nil)
                    }
                } else {
                    completionHandler(success: false, error: "Loading Current User Location Information Failed(Invalid Parsed Data)!")
                }
            }
            
        }
        task.resume()
    }
    
    // Post or Put User Location
    func registerUserLocation(lat: Double!, lon: Double!, mapString: String!, mediaURL: String!, completionHandler: (success: Bool, error: String?) -> Void){
        var messagePrefix: String
        var method: String
        if locationObjectId == nil {
            // new
            messagePrefix = "Posting"
            method = "POST"
        } else {
            // already created
            messagePrefix = "Updating"
            method = "PUT"
        }
        
        let request = getParseRequest(method, parameters: nil)
        let httpBodyString = "{\"uniqueKey\": \"\(UdacityClient.sharedInstance().userID!)\", \"firstName\": \"\(UdacityClient.sharedInstance().publicUserData!.firstName!)\", \"lastName\": \"\(UdacityClient.sharedInstance().publicUserData!.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(lat), \"longitude\": \(lon)}"
        request.HTTPBody = httpBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            let errorString = self.guardingForResponse("\(messagePrefix) Student Location", data: data, response: response, error: error)
            
            if errorString != nil {
                completionHandler(success: false, error: errorString)
                return
            }
            
            UdacityClient.parseJSONWithCompletionHandler(data!){
                JSONResult, error in
                if let result = JSONResult as? [String: AnyObject]{
                    print(result)
                    completionHandler(success: true, error: nil)
                } else
                {
                    completionHandler(success: false, error: "\(messagePrefix) Student Location Failed (Invalid Parsed Data)!")
                }
            }
            
        }
        task.resume()
    }
    
    // MARK: - Other API
    // Get country from mapString(city).
    func getStudentCountry(mapString:String?, completionHandler:(countryName: String?) -> Void) {
        
        guard mapString != nil else {
            completionHandler(countryName: nil)
            return
        }
        
        let params:[String: AnyObject] = [
            "callback" : "",
            "q" : mapString!,
            "_" : 1419120068976
        ]
        let locUrl = SharedConstants.FreeGeoAPI + UdacityClient.escapedParameters(params)
        let locRequest = NSMutableURLRequest(URL: NSURL(string: locUrl)!)
        let locSession = NSURLSession.sharedSession()
        let locTask = locSession.dataTaskWithRequest(locRequest) {locData, response, error in
            guard error == nil else {
                completionHandler(countryName: nil)
                return
            }
            UdacityClient.parseJSONWithCompletionHandler(locData!){
                JSONResult, error in
                var name: String? = nil
                if let result = JSONResult as? [String] {
                    var obj = result[0].componentsSeparatedByString(",")
                    if obj.count == 3 {
                        name = obj[2].stringByTrimmingCharactersInSet(NSCharacterSet())
                        name = (name! as NSString).substringFromIndex(1)
                        name = name?.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "-")
                    }
                }
                completionHandler(countryName: name)
            }
        }
        locTask.resume()
    }
    
    
    // MARK: - Common Request Settings for Parse access
    private func getParseRequest(method: String!, parameters: [String: AnyObject]?) -> NSMutableURLRequest {
        var urlString = UdacityClient.ParseAccessInfo.URLforStudentLocations
        if let params = parameters {
            urlString = urlString + UdacityClient.escapedParameters(params)
        } else if locationObjectId != nil {
            urlString = "\(urlString)/\(locationObjectId!))"
        }
        print(urlString)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL:url)
        request.HTTPMethod = method
        request.addValue(UdacityClient.ParseAccessInfo.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityClient.ParseAccessInfo.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        return request
    }
    
    
    // MARK: - Common Guard Procedure
    private func guardingForResponse(failTarget: String!, data: NSData?, response: NSURLResponse?, error: NSError?) -> String? {
        guard(error == nil) else {
            return "\(failTarget) Failed (Request Failed)!"
        }
        
        print(response)
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            if let _ = response as? NSHTTPURLResponse {
                return "\(failTarget) Failed (Access Denied)!"
            } else if let _ = response {
                return "\(failTarget) Failed (Invalid Response)!"
            } else {
                return "\(failTarget) Failed (No Response)!"
            }
        }
        
        guard let _ = data else {
            return "\(failTarget) Failed (No Data)!"
        }
        
        return nil
    }
    
    // MARK: - Class Func
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Helpers
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHnadler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do{
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHnadler(result: nil, error:  NSError(domain: "parseJSONWithCompetionHandler", code: 1, userInfo: userInfo))
        }
        completionHnadler(result: parsedResult, error: nil)
    }
    
    /* Helper: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String: AnyObject]) -> String {
        var urlVars = [String]()
        for(key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

}