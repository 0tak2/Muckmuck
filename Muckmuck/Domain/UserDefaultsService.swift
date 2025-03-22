//
//  UserDefaultsService.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    
    let repository: UserDefaultsRepository
    
    init(repository: UserDefaultsRepository = UserDefaultsRepository()) {
        self.repository = repository
    }
    
    func getUserOnboardingCompleted() -> Bool {
        return repository.get(.onboardingCompleted) ?? false
    }
    
    func setUserOnboardingCompleted(_ value: Bool) {
        repository.write(.onboardingCompleted, value)
    }
    
    func getUserId() -> UUID? {
        return UUID(uuidString: repository.get(.userId) ?? "")
    }
    
    func setUserId(_ value: UUID) {
        repository.write(.userId, value.uuidString)
    }
}
