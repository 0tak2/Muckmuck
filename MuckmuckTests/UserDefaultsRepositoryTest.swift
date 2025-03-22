//
//  UserDefaultsRepositoryTest.swift
//  MuckmuckTests
//
//  Created by 임영택 on 3/22/25.
//

import Foundation
import Testing
@testable import Muckmuck

struct UserDefaultsRepositoryTest {
    
    let repository = UserDefaultsRepository()

    @Test func readTest() async throws {
        let uuidString = UUID().uuidString
        UserDefaults.standard.set(uuidString, forKey: "userId")
        
        let fetchResult: String? = repository.get(.userId)
        #expect(fetchResult! == uuidString)
    }

    @Test func writeTest() async throws {
        repository.write(.onboardingCompleted, true)
        
        let fetchResult: Bool = UserDefaults.standard.bool(forKey: UserDefaultsRepository.UserDefaultsEntry.onboardingCompleted.rawValue)
        #expect(fetchResult)
    }
}
