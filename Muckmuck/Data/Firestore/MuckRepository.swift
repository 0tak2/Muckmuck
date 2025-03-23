//
//  MuckRepository.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation
import os.log
import FirebaseFirestore

final class MuckRepository {
    static let shared = MuckRepository()
    
    private let stack = FirestoreStack.shared
    
    private let userCollectionId = "users"
    private let muckTagCollectionId = "muckTags"
    private let muckReactionCollectionId = "muckReactions"
    private let log = Logger.of("MuckTagRepository")
    
    func setMuckTag(_ muckTag: MuckTag) async throws {
        do {
            try await stack.setDocument(
                for: [
                    "region": muckTag.region.getLocalizedString(),
                    "createdBy": muckTag.createdBy.id,
                    "createdAt": muckTag.createdAt,
                    "availableUntil": muckTag.availableUntil,
                    "type": muckTag.type.rawValue,
                    "isDeleted": muckTag.isDeleted
                ],
                id: muckTag.id.uuidString,
                for: muckTagCollectionId
            )
        } catch {
            log.error("error from firestore: \(error)")
            throw UserRepositoryError.firestoreError(error)
        }
    }
    
    func deleteMuckTag(_ muckTagId: UUID) async throws {
        do {
            guard var dict = try await stack.getDocument(collectionId: muckTagCollectionId, documentId: muckTagId.uuidString) else {
                throw UserRepositoryError.notFound
            }
            
            dict["isDeleted"] = true
            
            try await stack.setDocument(for: dict, id: muckTagId.uuidString, for: muckTagCollectionId)
        } catch let error as UserRepositoryError {
            throw error
        } catch {
            log.error("error from firestore: \(error)")
            throw UserRepositoryError.firestoreError(error)
        }
    }
    
    func getUser(id: String) async throws -> User {
        do {
            guard var userDictionary = try await stack.getDocument(collectionId: userCollectionId, documentId: id) else {
                throw UserRepositoryError.notFound
            }
            
            if let id = userDictionary["id"] as? String,
               let nickname = userDictionary["nickname"] as? String,
               let contackInfo = userDictionary["contactInfo"] as? String {
                return User (id: id, nickname: nickname, contactInfo: contackInfo)
            } else {
                log.error("every fields not resolved - getUser")
                throw UserRepositoryError.fieldsNotResolved
            }
        } catch let error as UserRepositoryError {
            throw error
        } catch {
            log.error("error from firestore: \(error)")
            throw UserRepositoryError.firestoreError(error)
        }
    }
    
    /**
     validOnly - true로 지정하는 경우 삭제되지 않았고 availableUntil 현재 시각 이전인 데이터만 조회한다.
     */
    func getMuckTags(validOnly: Bool = true) async throws -> [MuckTag] {
        do {
            let muckTagDictionaries = validOnly
            ? try await stack.getAllDocuments(collectionId: muckTagCollectionId, field1: "isDeleted", equalTo: false, field2: "availableUntil", greaterThan: Date())
            : try await stack.getAllDocuments(for: muckTagCollectionId)
            
            var muckTags: [MuckTag] = []
            for dict in muckTagDictionaries {
                if let muckTag = try await mapToMuckTag(dict) {
                    muckTags.append(muckTag)
                }
            }
            
            return muckTags
        } catch {
            log.error("error from firestore: \(error)")
            throw UserRepositoryError.firestoreError(error)
        }
    }
    
    func getMuckTag(of userId: String, validOnly: Bool = true) async throws -> [MuckTag] {
        do {
            let muckTagDictionaries = validOnly
            ? try await stack.getAllDocuments(collectionId: muckTagCollectionId, field1: "isDeleted", equalTo1: false, field2: "createdBy", equalTo2: userId, field3: "availableUntil", greaterThan: Date())
            : try await stack.getAllDocuments(collectionId: muckTagCollectionId, field: "createdBy", equalTo: userId)
            
            var muckTags: [MuckTag] = []
            for dict in muckTagDictionaries {
                if let muckTag = try await mapToMuckTag(dict) {
                    muckTags.append(muckTag)
                }
            }
            
            return muckTags
        } catch {
            log.error("error from firestore: \(error)")
            throw UserRepositoryError.firestoreError(error)
        }
    }
    
    func setMuckReaction(_ muckReaction: MuckReaction, muckTagId: UUID) async throws {
        do {
            try await stack.setDocument(
                for: [
                    "createdBy": muckReaction.createdBy.id,
                    "createdAt": muckReaction.createdAt,
                    "muckTagId": muckTagId.uuidString
                ],
                id: muckReaction.id.uuidString,
                for: muckReactionCollectionId
            )
        } catch {
            log.error("error from firestore: \(error)")
            throw UserRepositoryError.firestoreError(error)
        }
    }
    
    func getMuckReactions(muckTagId: UUID) async throws -> [MuckReaction] {
        do {
            let dictionaries = try await stack.getAllDocuments(collectionId: muckReactionCollectionId, field: "muckTagId", equalTo: muckTagId.uuidString)
            
            var reactions: [MuckReaction] = []
            for dict in dictionaries {
                if let muckReaction = try await mapToMuckReaction(dict) {
                    reactions.append(muckReaction)
                }
            }
            
            return reactions
        } catch {
            log.error("error from firestore: \(error)")
            throw UserRepositoryError.firestoreError(error)
        }
    }
    
    func getMuckReaction(userId: String, muckTagId: UUID) async throws -> MuckReaction? {
        do {
            let dictionaries = try await stack.getAllDocuments(collectionId: muckReactionCollectionId, field1: "muckTagId", equalTo1: muckTagId.uuidString, field2: "createdBy", equalTo2: userId)
            
            var reactions: [MuckReaction] = []
            for dict in dictionaries {
                if let muckReaction = try await mapToMuckReaction(dict) {
                    reactions.append(muckReaction)
                }
            }
            
            return reactions.first
        } catch {
            log.error("error from firestore: \(error)")
            throw UserRepositoryError.firestoreError(error)
        }
    }
    
    func removeMuckReaction(_ muckReaction: MuckReaction) async throws {
        do {
            try await stack.removeDocument(collectionId: muckReactionCollectionId, documentId: muckReaction.id.uuidString)
        } catch {
            log.error("error from firestore: \(error)")
            throw UserRepositoryError.firestoreError(error)
        }
    }
    
    func mapToMuckReaction(_ dict: [String: Any]) async throws -> MuckReaction? {
        if let idString = dict["id"] as? String,
           let id = UUID(uuidString: idString),
           let createdAtRaw = dict["createdAt"] as? Timestamp,
           let createdUserId = dict["createdBy"] as? String {
            let muckReaction = MuckReaction(id: id, createdBy: try await getUser(id: createdUserId), createdAt: createdAtRaw.dateValue())
            return muckReaction
        } else {
            log.warning("every fields not resolved - mapToMuckReaction")
            return nil
        }
    }
    
    func mapToMuckTag(_ dict: [String: Any]) async throws -> MuckTag? {
        if let idString = dict["id"] as? String,
           let id = UUID(uuidString: idString),
           let regionRaw = dict["region"] as? String,
           let createdAtRaw = dict["createdAt"] as? Timestamp,
           let availableUntilRaw = dict["availableUntil"] as? Timestamp,
           let muckTypeRaw = dict["type"] as? String,
           let createdUserId = dict["createdBy"] as? String,
           let isDeleted = dict["isDeleted"] as? Bool {
            let muckTag = MuckTag(id: id, region: MuckRegion.from(localizedString: regionRaw), createdBy: try await getUser(id: createdUserId), createdAt: createdAtRaw.dateValue(), availableUntil: availableUntilRaw.dateValue(), type: MuckType(rawValue: muckTypeRaw) ?? .bob, reactions: try await getMuckReactions(muckTagId: id), isDeleted: isDeleted)
            return muckTag
        } else {
            log.warning("every fields not resolved- mapToMuckTag")
            return nil
        }
    }
    
    enum UserRepositoryError: Error {
        case firestoreError(Error)
        case fieldsNotResolved
        case notFound
    }
}
