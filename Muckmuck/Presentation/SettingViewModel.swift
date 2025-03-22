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
        isError = false
        
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
