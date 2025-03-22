//
//  UserDefaultsRepository.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

final class UserDefaultsRepository {
    let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func get<T>(_ entry: UserDefaultsEntry) -> T? {
        if entry.getType() == String.self {
            return userDefaults.string(forKey: entry.rawValue) as? T
        }
        
        if entry.getType() == Int.self {
            return userDefaults.integer(forKey: entry.rawValue) as? T
        }
        
        if entry.getType() == Bool.self {
            return userDefaults.bool(forKey: entry.rawValue) as? T
        }
        
        return nil
    }
    
    func write(_ entry: UserDefaultsEntry, _ value: Any?) {
        userDefaults.set(value, forKey: entry.rawValue)
    }
    
    enum UserDefaultsEntry: String {
        case userId = "userId"
        case onboardingCompleted = "onboardingCompleted"
        
        func getType() -> Any.Type {
            switch self {
            case .userId:
                return String.self
            case .onboardingCompleted:
                return Bool.self
            }
        }
    }
}
