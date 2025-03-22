//
//  UserRepository.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation
import os.log

final class UserRepository {
    private let stack = FirestoreStack.shared
    
    private let collectionId = "users"
    private let log = Logger.of("UserRepository")
    
    func setUser(_ user: User) async throws {
        do {
            try await stack.setDocument(
                for: [
                    "nickname": user.nickname,
                    "contactInfo": user.contactInfo
                ],
                id: user.id,
                for: collectionId
            )
        } catch {
            log.error("error from firestore: \(error)")
            throw UserRepositoryError.firestoreError(error)
        }
    }
    
    func getUser(id: String) async throws -> User {
        do {
            let userDictionary = try await stack.getDocument(collectionId: collectionId, documentId: id)
            
            if let id = userDictionary["id"] as? String,
               let nickname = userDictionary["nickname"] as? String,
               let contackInfo = userDictionary["contactInfo"] as? String {
                return User (id: id, nickname: nickname, contactInfo: contackInfo)
            } else {
                log.error("every fields not resolved - getUser")
                throw UserRepositoryError.fieldsNotResolved
            }
        } catch {
            log.error("error from firestore: \(error)")
            throw UserRepositoryError.firestoreError(error)
        }
    }
    
    enum UserRepositoryError: Error {
        case firestoreError(Error)
        case fieldsNotResolved
    }
}
