//
//  UserService.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

final class UserService {
    let userRepository: UserRepository
    let defaultsRepository: UserDefaultsRepository
    
    init(
        userRepository: UserRepository,
        defaultsRepository: UserDefaultsRepository
    ) {
        self.userRepository = userRepository
        self.defaultsRepository = defaultsRepository
    }
    
    static let shared = UserService(userRepository: UserRepository(), defaultsRepository: UserDefaultsRepository())
    
    func getUserOnboardingCompleted() -> Bool {
        return defaultsRepository.get(.onboardingCompleted) ?? false
    }
    
    func setUserOnboardingCompleted(_ value: Bool) {
        defaultsRepository.write(.onboardingCompleted, value)
    }
    
    func getUserId() -> UUID? {
        return UUID(uuidString: defaultsRepository.get(.userId) ?? "")
    }
    
    func getCurrentUser() async throws -> User {
        guard let userId = getUserId() else {
            throw UserServiceError.userIdInvalid
        }
        
        return try await getUserFromRemote(id: userId)
    }
    
    private func getUserFromRemote(id: UUID) async throws -> User {
        try await userRepository.getUser(id: id)
    }
    
    func createNewUser(nickname: String = "", contactInfo: String = "팀즈로 연락해주세요") async throws -> User {
        let id = UUID()
        setUserId(id)
        
        do {
            try await setUserToRemote(User(id: id, nickname: nickname, contactInfo: contactInfo))
            setUserOnboardingCompleted(true)
            return User(id: id, nickname: nickname, contactInfo: contactInfo)
        } catch {
            throw UserServiceError.repositoryError(error)
        }
    }
    
    func updateUser(nickname: String, contactInfo: String) async throws -> User {
        guard let id = getUserId() else {
            throw UserServiceError.userIdInvalid
        }
        
        do {
            try await setUserToRemote(User(id: id, nickname: nickname, contactInfo: contactInfo))
            return User(id: id, nickname: nickname, contactInfo: contactInfo)
        } catch {
            throw UserServiceError.repositoryError(error)
        }
    }
    
    private func setUserId(_ value: UUID) {
        defaultsRepository.write(.userId, value.uuidString)
    }
    
    private func setUserToRemote(_ user: User) async throws {
        try await userRepository.setUser(user)
    }
    
    enum UserServiceError: Error {
        case repositoryError(Error)
        case userIdInvalid
    }
}
