//
//  SettingView.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import SwiftUI

struct SettingView: View {
    @State private var nickname: String = ""
    @State private var contactInfo: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("닉네임", text: $nickname)
                    TextField("연락 방법", text: $contactInfo)
                }
                
                Section {
                    Text("유저 고유ID")
                    TextField("유저 고유ID", text: .constant(String(UUID().uuidString.split(separator: "-").first ?? "")))
                }
                
                Section {
                    Text("Version 0.0.1")
                }
            }
            .navigationTitle("설정")
            .toolbar {
                Button {
                    endEditing()
                } label: {
                    Text("저장")
                }

            }
        }
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
}

#Preview {
    SettingView()
}
