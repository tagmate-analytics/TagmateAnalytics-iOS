//
//  ViewController.swift
//  TagmateAnalytics
//
//  Created by tatvic user on 21/06/23.
//

import UIKit
import FirebaseAnalytics
import FirebaseCore

class ViewController: UIViewController {

    //https://www.youtube.com/watch?v=o3Rkg6WmZoY
    
    var optionalValue: String!
    var bundleId: String!
    var tagmateAnalytics: TagmateAnalytics!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        getDevice()
//        getBundleId()
//        apiCallPost()
        
//        FirebaseApp.configure()
        
        
//        FirebaseApp.configure()
        
//        TagmateAnalytics.configure()
        tagmateAnalytics = TagmateAnalytics()
        TagmateAnalytics.logEvent(eventName: "home_screen_visible", parameter: [
            "key_1":"abc_param",
            "key_2":"param_2"
        ])
        
        TagmateAnalytics.setUserProperty(value: "realEstate", forName: "Property")
        
        Analytics.logEvent("fjdsgfbjhsdb", parameters: [
            AnalyticsParameterQuantity: "3",
            AnalyticsEventViewItem: "Viewitem"
            
        ])
        
    
        
        print("Custom model number ", modelIdentifier() )
        
        let button = UIButton()
        button.setTitle("Tagmate Button", for: .normal)
        button.backgroundColor = .systemBlue
        view.addSubview(button)
        
        button.frame = CGRect(x: 100, y: 100, width: 200, height: 150)
        button.layer.cornerRadius = 50

        button.addTarget(self, action: #selector(buttonTrapped), for: .touchUpInside)
    }
    
    @objc func buttonTrapped(){
        view.backgroundColor = .systemCyan
        
        TagmateAnalytics.logEvent(eventName: "jaidada", parameter: [
            "abc":"abc_param",
            "key_2":"param_2"
        ])
        
        TagmateAnalytics.logEvent(eventName: "BUTTON_CLICKED", parameter: [
            "BUTTON_CLICKEDDD":"HEY"
            
        ])
        
        getBundleId()
        
    }
    
    func getBundleId(){
//        optionalValue = Bundle.main.bundleIdentifier
//        print("My OPTION value is ", optionalValue)
        
//
//        if var bundleId2 = optionalValue {
//            // Use the bundleId here
//            print(bundleId)
//            bundleId = bundleId2
//            print("Main  b id ", bundleId)
//
//        } else {
//            // Handle the case when the value is nil
//            print("The bundleId is nil")
//        }
        
        if let retrievedBundleId = Bundle.main.bundleIdentifier {
            bundleId = retrievedBundleId
            print("bundle id ", bundleId)
        } else {
            print("Unable to retrieve the bundle ID")
        }
        
        
    }
    
    
    func getDevice(){
        print("Device ID: ",UIDevice.current.identifierForVendor!.uuidString)
        print("Device Name: ",UIDevice.current.name)
    }
    
//    "https://debugger-dev.tagmate.app/api/v1/debugger/appRequests/check/device"
    
    func apiCallPost(){
        guard let url = URL(string: "http://192.168.0.218:3050/api/v1/debugger/appRequests/check/device") else {
            return
        }
        
        print("BASE_URL", url)
        
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
            
//            print("RESPONSE_CODE ",httpResponse.statusCode)

            
            guard let data = data, error == nil else{
                return
            }
            
            do{
                let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("SUCCESS: \(response)")
            }
            catch{
                print(error.localizedDescription)
                print(error)

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
    
}

