//
//  MuckService.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation
import os.log

final class MuckService {
    static let shared = MuckService()
    
    private let muckRepository: MuckRepository
    private let log = Logger.of("MuckService")
    
    init(muckRepository: MuckRepository = MuckRepository.shared) {
        self.muckRepository = muckRepository
    }
    
    // FIXME: 내가 소유하지 않은 엔티티를 업데이트하는 경우 방지
    func saveMuckTag(_ muckTag: MuckTag) async throws {
        if muckTag.availableUntil < Date() {
            throw MuckServiceError.availableDateInvalid
        }
        
        do {
            try await muckRepository.setMuckTag(muckTag)
        } catch {
            throw MuckServiceError.repositoryError(error)
        }
    }
    
    // FIXME: 내가 소유하지 않은 엔티티를 삭제하는 경우 방지
    func deleteMuckTag(id: UUID) async throws {
        do {
            try await muckRepository.deleteMuckTag(id)
        } catch {
            throw MuckServiceError.repositoryError(error)
        }
    }
    
    func getMuckTag(of userId: String) async throws -> [MuckTag] {
        do {
            let result = try await muckRepository.getMuckTag(of: userId)
            if result.count > 1 {
                log.warning("getMuckTag of userId=\(userId) => result set length is more than 1")
            }
            return result
        } catch {
            throw MuckServiceError.repositoryError(error)
        }
    }
    
    func getValidMuckTags() async throws -> [MuckTag] {
        do {
            return try await muckRepository.getMuckTags()
        } catch {
            throw MuckServiceError.repositoryError(error)
        }
    }
    
    func saveReaction(reaction: MuckReaction, muckTagId: UUID) async throws {
        do {
            try await muckRepository.setMuckReaction(reaction, muckTagId: muckTagId)
        } catch {
            throw MuckServiceError.repositoryError(error)
        }
    }
    
    func toggleReaction(userId: String, muckTagId: UUID) async throws {
        do {
            let reaction = try await muckRepository.getMuckReaction(userId: userId, muckTagId: muckTagId)
            
            if let reaction = reaction {
                try await muckRepository.removeMuckReaction(reaction)
            } else {
                try await muckRepository.setMuckReaction(MuckReaction(id: UUID(), createdBy: User(id: userId, nickname: "", contactInfo: ""), createdAt: Date()), muckTagId: muckTagId)
            }
        }
    }
    
    enum MuckServiceError: Error {
        case repositoryError(Error)
        case userIdInvalid
        case availableDateInvalid
        
        func getUserMessage() -> String {
            switch self {
            case .repositoryError(let error):
                return "서버 에러가 발생했습니다.\n\(error)"
            case .userIdInvalid:
                return "아이디를 참조할 수 없습니다."
            case .availableDateInvalid:
                return "현재 시각 이후의 시점을 입력해주세요."
            }
        }
    }
}
