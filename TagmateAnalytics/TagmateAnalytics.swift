//
//  TagmateAnalytics.swift
//  TagmateAnalytics
//
//  Created by Kuldeep Rathod on 26/06/23.

import Foundation
import UIKit
import FirebaseAnalytics
import Firebase


class TagmateAnalytics{
    
    var optionalValue: String!
    var bundleId: String!
    var appInstanceID: String!
    var currentSessionID: Any!
    let apiUrl: String = "https://debugger-dev.tagmate.app/api/v1/debugger/appRequests/check/device"
    
    
    static func configure(){
        print("Firebase will initialize here....")
        FirebaseApp.configure()
        
        var tagmateAnaltics = TagmateAnalytics()
        tagmateAnaltics.getBundleId()
                tagmateAnaltics.apiCheckDevice()
    }
    
    func getBundleId(){
        if let retrievedBundleId = Bundle.main.bundleIdentifier {
            bundleId = retrievedBundleId
            print("bundle id ", bundleId)
        } else {
            print("Unable to retrieve the bundle ID")
        }
    }
    
    private func apiCheckDevice(){
        guard let url = URL(string: apiUrl) else {
            print("URL not getting")
            return
        }
        var request = URLRequest(url: url)
               
               request.httpMethod = "POST"
               request.setValue("application/json", forHTTPHeaderField: "Content-Type")
               let body: [String: Any] = [
                   "packageName": bundleId,
                   "deviceId": UIDevice.current.identifierForVendor!.uuidString,
                   "modelName": UIDevice.current.name,
                   "modelNumber": modelIdentifier(),
               ]
               
               print("YOUR_BODY ", body)
               
               request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
               
               //make the request
               let task = URLSession.shared.dataTask(with: request){ data, response, error in
                   
                   if let error = error {
                         print("Post Request Error: \(error.localizedDescription)")
                         return
                       }
                       
                   
                   let httpResponse = response as? HTTPURLResponse
                   print("RESPONSE_CODE ", httpResponse?.statusCode)
                   
                       // ensure there is valid response code returned from this HTTP response
                       guard let httpResponse = response as? HTTPURLResponse,
                             (200...299).contains(httpResponse.statusCode)
                               
                       else {
                         print("Invalid Response received from the server")
                         return
                       }
                   
                   guard let data = data, error == nil else{
                       return
                   }
                   
                   do{
                       let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                       print("SUCCESSSSSSSSSSSSSSSSSS: \(response)")
                       
                       if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                  // Access the "data" key and its value
                           
                           print("JObject: ", jsonObject)
                           
                                  if let data = jsonObject["data"] as? [String: Any] {
                                      // Check if the "sessionId" key exists
                                      
                                      print("DatA get", data["sessionId"])
                                      
                                      
                                      if data["sessionId"] != nil {
                                          print("OUR SESSION::: ", data["sessionId"])
                                          self.currentSessionID = data["sessionId"]
                                          print("MY SESSION ID", self.currentSessionID)
                                      } else{
                                          self.currentSessionID = "";
                                          print("Session ID not found!")
                                      }
                                  } else {
                                      print("Key 'data' not found or value is not a dictionary")
                                  }
                              } else {
                                  print("Invalid JSON format")
                              }
                       
                   }
                   catch{
                       print(error.localizedDescription)
                       print(error)
                   }
               }
               task.resume()
    }
    
    func sendLogEvent(eventName: String, parameter: [String : Any]?) {
          print("sessionID::::::", self.currentSessionID)
          guard let url = URL(string: "https://debugger-dev.tagmate.app/api/v1/debugger/appRequests") else {
              print("Invalid URL")
              return
          }
          
          var request = URLRequest(url: url)
          request.httpMethod = "POST"
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          
          getBundleId()
          
          print("MY SESSION ID in appReq", self.currentSessionID)
          
          let payload: [String: Any] = [
              "event_name": eventName,
              "params": parameter,
              "meta": [
                  "app_instance_id": Analytics.appInstanceID(),
                  "app_package_name": bundleId,
                  "sessionId": currentSessionID,
                  "deviceId": UIDevice.current.identifierForVendor!.uuidString
              ]
          ]
          
          print("Device ID: ",UIDevice.current.identifierForVendor!.uuidString)
          print("Device Name: ",UIDevice.current.name)
          
          do {
              let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
              print("jsonData", payload)
              request.httpBody = jsonData
          } catch {
              print("Error creating JSON data: \(error)")
              return
          }
          
          let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
              if let error = error {
                  print("Error: \(error)")
                  return
              }
              
              guard let httpResponse = response as? HTTPURLResponse else {
                  print("Invalid response")
                  return
              }
              
              print("Response code: \(httpResponse.statusCode)")
              
              if let data = data {
                  // Handle the response data here
                  // You can parse the data assuming it's in JSON format
                  
                  do {
                      let json = try JSONSerialization.jsonObject(with: data, options: [])
                      // Handle the JSON response
                      
                      if let jsonDict = json as? [String: Any], let responseCode = jsonDict["response_code"] as? Int {
                          // Handle the response code
                          print("Response code: \(responseCode)")
                      }
                      
                      // Handle other response data as needed
                      
                  } catch {
                      print("Error parsing JSON response: \(error)")
                  }
              }
          }
          task.resume()
      }
    
    func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    func getModelNumber() -> String? {
        let device = UIDevice.current
        return device.model
    }
    
    public static func logEvent(eventName: String, parameter: [String : Any]?){
        Analytics.logEvent(eventName, parameters: parameter)
        
        let tagmateAnaltics = TagmateAnalytics()
        
        tagmateAnaltics.sendLogEvent(eventName: eventName, parameter: parameter)
        
    }
    
    public static func setUserProperty(value: String?, forName: String){
        Analytics.setUserProperty(value, forName: forName)        
    }
    
    public static func setUserID(userID: String?){
        Analytics.setUserID(userID)
    }
    
    public static func setAnalyticsCollectionEnabled(analyticsCollectionEnabled: Bool){
        Analytics.setAnalyticsCollectionEnabled(analyticsCollectionEnabled)
    }
    
    public static func setSessionTimeoutInterval(sessionTimeoutInterval: TimeInterval){
        Analytics.setSessionTimeoutInterval(sessionTimeoutInterval)
    }
    
    public static func appInstanceID(){
        Analytics.appInstanceID()
    }
    
    public static func resetAnalyticsData(){
        Analytics.resetAnalyticsData()
    }

    public static func setDefaultEventParameters(parameters: [String : Any]?){
        Analytics.setDefaultEventParameters(parameters)
    }
}


