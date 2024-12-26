//
//  WorkFocusNotification.swift
//  WorkFocus
//
//  Created by Rustam Rusaliev on 19/12/24.
//

import Foundation
import UserNotifications

class WorkFocusNotification{
    
    static func checkAuthorization(completion: @escaping (Bool) -> Void){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings{settings in
            switch settings.authorizationStatus{
                case .authorized:
                completion(true)
            case.notDetermined:
                notificationCenter.requestAuthorization(options: [.alert,. badge,. sound]){allowed, error in
                    completion(allowed)
                }
            default:
                completion(false)
            }
        }
    }
    static func scheduleNotification(seconds:TimeInterval, title: String, body: String){
        let notificationCenter = UNUserNotificationCenter.current()
        //remove all notifications
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
        //set up content
        let content = UNMutableNotificationContent()
        content.body = body
        content.title = title
        content.sound = .default
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue:WorkFocusAudioSounds.done.resource))
        //trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        //create request
        let request = UNNotificationRequest(identifier: "my-notifciation", content: content, trigger: trigger)
        //add the notification to the center
        notificationCenter.add(request)
        
    }
}
