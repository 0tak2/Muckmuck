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
    private let stack = FirestoreStack.shared
    
    private let userCollectionId = "users"
    private let muckTagCollectionId = "muckTags"
    private let log = Logger.of("MuckTagRepository")
    
    func setMuckTag(_ muckTag: MuckTag) async throws {
        do {
            try await stack.setDocument(
                for: [
                    "region": muckTag.region.getLocalizedString(),
                    "createdBy": muckTag.createdBy.id.uuidString,
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
    
    func getUser(id: UUID) async throws -> User {
        do {
            let userDictionary = try await stack.getDocument(collectionId: userCollectionId, documentId: id.uuidString)
            if let idString = userDictionary["id"] as? String,
               let id = UUID(uuidString: idString),
               let nickname = userDictionary["nickname"] as? String,
               let contackInfo = userDictionary["contactInfo"] as? String {
                return User (id: id, nickname: nickname, contactInfo: contackInfo)
            } else {
                log.error("every fields not resolved")
                throw UserRepositoryError.fieldsNotResolved
            }
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
    
    func getMuckTag(of userId: UUID, validOnly: Bool = true) async throws -> [MuckTag] {
        do {
            let muckTagDictionaries = validOnly
            ? try await stack.getAllDocuments(collectionId: muckTagCollectionId, field1: "isDeleted", equalTo1: false, field2: "createdBy", equalTo2: userId.uuidString, field3: "availableUntil", greaterThan: Date())
            : try await stack.getAllDocuments(collectionId: muckTagCollectionId, field: "createdBy", equalTo: userId.uuidString)
            
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
    
    func mapToMuckTag(_ dict: [String: Any]) async throws -> MuckTag? {
        if let idString = dict["id"] as? String,
           let id = UUID(uuidString: idString),
           let regionRaw = dict["region"] as? String,
           let createdAtRaw = dict["createdAt"] as? Timestamp,
           let availableUntilRaw = dict["availableUntil"] as? Timestamp,
           let muckTypeRaw = dict["type"] as? String,
           let createdUserIdRaw = dict["createdBy"] as? String,
           let createdUserId = UUID(uuidString: createdUserIdRaw),
           let isDeleted = dict["isDeleted"] as? Bool {
            let muckTag = MuckTag(id: id, region: MuckRegion.from(localizedString: regionRaw), createdBy: try await getUser(id: createdUserId), createdAt: createdAtRaw.dateValue(), availableUntil: availableUntilRaw.dateValue(), type: MuckType(rawValue: muckTypeRaw) ?? .bob, reactions: [], isDeleted: isDeleted)
            return muckTag
        } else {
            log.warning("every fields not resolved")
            return nil
        }
    }
    
    enum UserRepositoryError: Error {
        case firestoreError(Error)
        case fieldsNotResolved
    }
}
