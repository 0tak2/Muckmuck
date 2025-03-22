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
    
    init(muckRepository: MuckRepository = MuckRepository()) {
        self.muckRepository = muckRepository
    }
    
    func addNewMuckTag(_ muckTag: MuckTag) async throws {
        if muckTag.availableUntil < Date() {
            throw MuckServiceError.availableDateInvalid
        }
        
        do {
            try await muckRepository.setMuckTag(muckTag)
        } catch {
            throw MuckServiceError.repositoryError(error)
        }
    }
    
    func getMuckTag(of userId: UUID) async throws -> [MuckTag] {
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
