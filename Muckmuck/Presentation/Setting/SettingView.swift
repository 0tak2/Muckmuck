//
//  SettingView.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject private var userProfileModel: UserProfileModel
    @StateObject private var settingViewModel = SettingViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("닉네임", text: $settingViewModel.editingUserNickname)
                    TextField("연락 방법", text: $settingViewModel.editingUserContactInfo)
                }
                
                Section {
                    Text("유저 고유ID")
                    Text(userProfileModel.currentUser?.id ?? "Invalid")
                    Button {
                        settingViewModel.showSignOutAlert = true
                    } label: {
                        Text("회원 탈퇴")
                    }
                }
                
                Section {
                    Text("Version 0.0.1")
                }
            }
            .navigationTitle("설정")
            .toolbar {
                Button {
                    settingViewModel.saveButtonTapped()
                } label: {
                    Text("저장")
                }
            }
            .alert("저장이 완료되었습니다.", isPresented: $settingViewModel.showCompleteAlert) {
                Button("확인", role: .cancel) {
                    userProfileModel.settingNeeded = false
                    settingViewModel.endEditing()
                }
            }
            .alert(settingViewModel.errorMessage, isPresented: $settingViewModel.isError) {
                Button("확인", role: .cancel) { }
            }
            .alert("정말로 탈퇴하시겠습니까?", isPresented: $settingViewModel.showSignOutAlert) {
                Button("취소", role: .cancel) { }
                
                Button("탈퇴", role: .destructive) {
                    // FIXME: Two view models are used separately
                    settingViewModel.signOut()
                    userProfileModel.onboardingNeeded = true
                    userProfileModel.settingNeeded = true
                }
            }
        }
        .onAppear {
            settingViewModel.onAppear()
        }
    }
}

#Preview {
    SettingView()
        .environmentObject(UserProfileModel())
}
