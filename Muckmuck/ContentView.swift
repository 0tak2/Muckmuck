//
//  ContentView.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MuckTagListView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("먹먹")
                }
            
            SettingView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("설정")
                }
        }
    }
}

#Preview {
    ContentView()
}
