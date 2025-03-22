//
//  SettingViewModel.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation
import SwiftUI

final class SettingViewModel: ObservableObject {
    private let userService: UserService
    
    init(userService: UserService = UserService.shared) {
        self.userService = userService
    }
    
    @Published var editingUserNickname: String = ""
    @Published var editingUserContactInfo: String = ""
    @Published var isError: Bool = false
    @Published var errorMessage: String = "오류가 발생했습니다."
    @Published var showCompleteAlert: Bool = false
    
    func onAppear() {
        Task {
            do {
                let user = try await userService.getCurrentUser()
                await MainActor.run {
                    editingUserNickname = user.nickname
                    editingUserContactInfo = user.contactInfo
                }
            } catch {
                isError = true
            }
        }
    }
    
    func save() {
        guard editingUserNickname != "" else {
            isError = true
            errorMessage = "닉네임은 공백일 수 없습니다."
            return
        }
        
        isError = false
        errorMessage = "오류가 발생했습니다."
        
        Task {
            do {
                let _ = try await userService.updateUser(nickname: editingUserNickname, contactInfo: editingUserContactInfo)
                await MainActor.run {
                    showCompleteAlert = true
                }
            } catch {
                isError = true
            }
        }
    }
    
    func saveButtonTapped() {
        save()
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
}
