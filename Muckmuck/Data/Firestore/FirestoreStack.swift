//
//  FirestoreStack.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import os.log
import FirebaseFirestore

final class FirestoreStack {
    static let shared: FirestoreStack = FirestoreStack()
    var db: Firestore?
    
    private var logger = Logger.of("FirestoreStack")
    
    func setDb(_ db: Firestore) {
        self.db = db
    }
    
    func getAllDocuments(for collectionId: String) async throws -> [[String: Any]] {
        guard let db = db else {
            logger.error("db가 초기화되지 않았습니다")
            fatalError("db must be init!")
        }
        
        do {
            logger.debug("start getAllDocuments for \(collectionId)")
            let snapshot = try await db.collection(collectionId).getDocuments()
            return snapshot.documents.map { document in
                var data = [String: Any]()
                data["id"] = document.documentID
                data.merge(document.data()) { (_, new) in new }
                return data
            }
        } catch {
            logger.error("Error getting documents: \(error)")
            throw error
        }
    }
    
    func getAllDocuments<T>(collectionId: String, field: String, equalTo: T) async throws -> [[String: Any]] {
        guard let db = db else {
            logger.error("db가 초기화되지 않았습니다")
            fatalError("db must be init!")
        }
        
        do {
            logger.debug("start getAllDocuments for \(collectionId)")
            let snapshot = try await db.collection(collectionId).whereField(field, isEqualTo: equalTo).getDocuments()
            return snapshot.documents.map { document in
                var data = [String: Any]()
                data["id"] = document.documentID
                data.merge(document.data()) { (_, new) in new }
                return data
            }
        } catch {
            logger.error("Error getting documents: \(error)")
            throw error
        }
    }
    
    func getAllDocuments<T, R>(collectionId: String, field1: String, equalTo: T, field2: String, greaterThan: R) async throws -> [[String: Any]] {
        guard let db = db else {
            logger.error("db가 초기화되지 않았습니다")
            fatalError("db must be init!")
        }
        
        do {
            logger.debug("start getAllDocuments for \(collectionId)")
            let snapshot = try await db.collection(collectionId)
                .whereField(field1, isEqualTo: equalTo)
                .whereField(field2, isGreaterThan: greaterThan)
                .getDocuments()
            return snapshot.documents.map { document in
                var data = [String: Any]()
                data["id"] = document.documentID
                data.merge(document.data()) { (_, new) in new }
                return data
            }
        } catch {
            logger.error("Error getting documents: \(error)")
            throw error
        }
    }
    
    func getAllDocuments<T, S, R>(collectionId: String, field1: String, equalTo1: T, field2: String, equalTo2: S, field3: String, greaterThan: R) async throws -> [[String: Any]] {
        guard let db = db else {
            logger.error("db가 초기화되지 않았습니다")
            fatalError("db must be init!")
        }
        
        do {
            logger.debug("start getAllDocuments for \(collectionId)")
            let snapshot = try await db.collection(collectionId)
                .whereField(field1, isEqualTo: equalTo1)
                .whereField(field2, isEqualTo: equalTo2)
                .whereField(field3, isGreaterThan: greaterThan)
                .getDocuments()
            return snapshot.documents.map { document in
                var data = [String: Any]()
                data["id"] = document.documentID
                data.merge(document.data()) { (_, new) in new }
                return data
            }
        } catch {
            logger.error("Error getting documents: \(error)")
            throw error
        }
    }
    
    func getDocument(collectionId: String, documentId: String) async throws -> [String: Any] {
        guard let db = db else {
            logger.error("db가 초기화되지 않았습니다")
            fatalError("db must be init!")
        }
        
        do {
            logger.debug("start getAllDocuments for \(collectionId)")
            let document = try await db.collection(collectionId).document(documentId).getDocument()
            
            var data = [String: Any]()
            data["id"] = document.documentID
            if let documentData = document.data() {
                data.merge(documentData) { (_, new) in new }
            }
            
            return data
        } catch {
            logger.error("Error getting documents: \(error)")
            throw error
        }
    }
    
    func setDocument(for document: [String: Any], id: String, for collectionId: String) async throws {
        guard let db = db else {
            logger.error("db가 초기화되지 않았습니다")
            fatalError("db must be init!")
        }
        
        do {
            logger.debug("start setDocument to \(collectionId) for \(document)")
            try await db.collection(collectionId).document(id).setData(document)
        } catch {
            logger.error("Error writing documents: \(error)")
            throw error
        }
    }
}
