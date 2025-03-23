//
//  ContentViewModel.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation
import os.log

final class UserProfileModel: ObservableObject {
    private let userService: UserService
    private let log = Logger.of("UserProfileModel")
    
    init(
        userService: UserService = UserService.shared
    ) {
        self.userService = userService
    }
    
    @Published var onboardingNeeded = false
    @Published var currentUser: User?
    @Published var settingNeeded = false
    
    func onAppeared() {
        onboardingNeeded = !userService.getUserOnboardingCompleted()
        
        if !onboardingNeeded {
            initUserProfile()
        }
    }
    
    func initUserProfile() {
        guard userService.getUserOnboardingCompleted() else {
            onboardingNeeded = true
            return
        }
        
        Task {
            do {
                let userEntity = try await userService.getCurrentUser()
                await MainActor.run {
                    currentUser = userEntity
                    settingNeeded = userEntity.nickname == ""
                }
                log.info("initUserProfile success")
            } catch {
                log.error("initUserProfile failed... \(error)")
            }
        }
    }
    
    func onboardingComplete() {
        Task {
            do {
                let userEntity = try await userService.createNewUser()
                try await userService.updateNotificationToken()
                await MainActor.run {
                    currentUser = userEntity
                    onboardingNeeded = false
                    settingNeeded = true
                }
                log.info("create user success")
            } catch {
                log.error("create user failed... \(error)")
            }
        }
    }
}
