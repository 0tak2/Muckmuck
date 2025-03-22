//
//  ContentView.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userProfileModel = UserProfileModel()
    @State private var currentTabIndex = 0
    
    var body: some View {
        TabView(selection: $currentTabIndex) {
            MuckTagListView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("먹먹")
                }
                .tag(0)
            
            SettingView()
                .environmentObject(userProfileModel)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("설정")
                }
                .tag(1)
        }
        .onAppear {
            userProfileModel.onAppeared()
        }
        .sheet(isPresented: $userProfileModel.onboardingNeeded) {
            OnboardingView()
                .environmentObject(userProfileModel)
        }
        .onChange(of: userProfileModel.settingNeeded) { _, currentValue in
            if currentValue {
                currentTabIndex = 1
            }
        }
    }
}

#Preview {
    ContentView()
}
