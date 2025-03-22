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
    
    func onAppeared() {
        onboardingNeeded = !userService.getUserOnboardingCompleted()
        
        if !onboardingNeeded {
            loadUserProfile()
        }
    }
    
    func loadUserProfile() {
        guard let _ = userService.getUserId() else {
            onboardingNeeded = true
            return
        }
        
        Task {
            let userEntity = try await userService.getCurrentUser()
            await MainActor.run {
                currentUser = userEntity
            }
        }
    }
    
    func onboardingComplete() {
        Task {
            do {
                let userEntity = try await userService.createNewUser()
                
                await MainActor.run {
                    currentUser = userEntity
                    onboardingNeeded = false
                }
            } catch {
                log.error("create user failed...")
            }
        }
    }
}
