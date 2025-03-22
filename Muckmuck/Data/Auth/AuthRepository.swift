//
//  AuthRepository.swift
//  Muckmuck
//
//  Created by 임영택 on 3/23/25.
//

import Foundation
import FirebaseAuth

final class AuthRepository {
    typealias UserID = String
    
    func login() async throws -> UserID? {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signInAnonymously { authResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: authResult?.user.uid)
            }
        }
    }
}
