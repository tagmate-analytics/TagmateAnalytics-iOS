//
//  TagmateAnalytics.swift
//  TagmateAnalytics
//
//  Created by tatvic user on 26/06/23.
//

import Foundation
import UIKit
import FirebaseAnalytics


class TagmateAnalytics{
    
    static func configure(){
        print("Firebase will initialize here...")
    }
    
    public static func logEvent(eventName: String, parameter: [String : Any]?){
        Analytics.logEvent(eventName, parameters: parameter)
    }
    
    public static func setUserProperty(value: String?, forName: String){
        Analytics.setUserProperty(value, forName: forName)
//        Analytics.setUserProperty(<#T##value: String?##String?#>, forName: <#T##String#>)
    }
    
    
    public static func setUserID(userID: String?){
        Analytics.setUserID(userID)
    }
    
    public static func setAnalyticsCollectionEnabled(analyticsCollectionEnabled: Bool){
        Analytics.setAnalyticsCollectionEnabled(analyticsCollectionEnabled)
    }
    
    public static func setSessionTimeoutInterval(sessionTimeoutInterval: TimeInterval){
        Analytics.setSessionTimeoutInterval(<#T##sessionTimeoutInterval: TimeInterval##TimeInterval#>)
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
//var TagmateParamQuantity =  AnalyticsParameterQuantity
//var TagmatekParameterAchievementID = AnalyticsParameterAchievementID


