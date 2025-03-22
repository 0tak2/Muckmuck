//
//  AppDelegate.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // MARK: INIT Firebase
        FirebaseApp.configure()
        FirestoreStack.shared.setDb(Firestore.firestore())
        return true
    }
}
