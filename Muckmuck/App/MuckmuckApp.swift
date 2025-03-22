//
//  MuckmuckApp.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import SwiftUI

@main
struct MuckmuckApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
