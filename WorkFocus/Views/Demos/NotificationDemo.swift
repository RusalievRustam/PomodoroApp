//
//  NotificationDemo.swift
//  WorkFocus
//
//  Created by Rustam Rusaliev on 19/12/24.
//

import SwiftUI

struct NotificationDemo: View {
    @State private var showWarning = false
    @Environment(\.scenePhase) var scenePhase
    var body : some View {
        VStack{
            Button("send notfication"){
                WorkFocusNotification.scheduleNotification(seconds: 5,
                    title: "This is a title", body: "Some message")
        }
            if showWarning{
                VStack{
                    Text ("Notifications are disabled")
                    Button("Enable"){
                        //open settings
                        DispatchQueue.main.async {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:],
                                                      completionHandler: nil)
                        }
                    }
                    
                }
            }
    }
        .onChange(of: scenePhase){ 
            if scenePhase == .active{
                WorkFocusNotification.checkAuthorization{ authorized in
                    showWarning = !authorized}
            }
        }
        }
    }


#Preview {
    NotificationDemo()
}
