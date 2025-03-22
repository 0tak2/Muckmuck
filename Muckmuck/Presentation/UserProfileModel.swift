//
//  ContentViewModel.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

final class UserProfileModel: ObservableObject {
    private let userDefaultsService: UserDefaultsService
    
    init(userDefaultsService: UserDefaultsService = UserDefaultsService.shared) {
        self.userDefaultsService = userDefaultsService
    }
    
    @Published var onboardingNeeded = false
    @Published var currentUser: User?
    
    func onAppeared() {
        onboardingNeeded = !userDefaultsService.getUserOnboardingCompleted()
        
        if !onboardingNeeded {
            loadUserProfile()
        }
    }
    
    func loadUserProfile() {
        guard let userId = userDefaultsService.getUserId() else {
            onboardingNeeded = true
            return
        }
        
        // TODO: Get user info by userId
        
        currentUser = User(id: userId, nickname: "닉네임", contactInfo: "팀즈")
    }
    
    func onboardingComplete() {
        userDefaultsService.setUserId(UUID())
        userDefaultsService.setUserOnboardingCompleted(true)
        onboardingNeeded = false
    }
}
