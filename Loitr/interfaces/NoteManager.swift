//
//  NoteManager.swift
//  Loitr
//
//  Created by Timothy Dillman on 5/2/19.
//  Copyright © 2019 Timothy Dillman. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

protocol NoteManagerDelegate: class {
    func noteManagerAuthorizationStatus(status authorized: Bool)
}

final class NoteManager: NSObject {
    
    static let instance: NoteManager = NoteManager()
    
    weak var delegate: NoteManagerDelegate?
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: notificationSettingsHandler(settings:))
    }
    
    func didRegisterRemoteNotifications(dataToken token: Data) {
        print(String(data: token, encoding: .utf8) ?? "Cannot decode token")
    }
    
    func scheduleNote(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        let note = UNNotificationRequest(identifier: "Loitr", content: content, trigger: .none)
        UNUserNotificationCenter.current().add(note, withCompletionHandler: nil)
    }
    
    private func notificationSettingsAuthorizationHandler(authorized: Bool, error: Error?) {
        if authorized {
            DispatchQueue.main.async {
                UIApplication.shared.unregisterForRemoteNotifications()
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        delegate?.noteManagerAuthorizationStatus(status: authorized)
    }
    
    private func notificationSettingsHandler(settings: UNNotificationSettings) {
        switch settings.authorizationStatus {
        case .authorized:
            delegate?.noteManagerAuthorizationStatus(status: true)
            if #available(iOS 12.0, *) {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .criticalAlert, .carPlay, .sound], completionHandler: notificationSettingsAuthorizationHandler)
            } else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound], completionHandler: notificationSettingsAuthorizationHandler)
            }
        case .denied:
            delegate?.noteManagerAuthorizationStatus(status: false)
        default:
            if #available(iOS 12.0, *) {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .criticalAlert, .carPlay, .sound], completionHandler: notificationSettingsAuthorizationHandler)
            } else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound], completionHandler: notificationSettingsAuthorizationHandler)
            }
        }
    }
    
}

extension NoteManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
}
