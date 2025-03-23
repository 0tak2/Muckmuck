//
//  UserService.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation
import Combine

final class UserService {
    let authRepository: AuthManager
    let userRepository: UserRepository
    let messagingManager: MessagingManager
    let defaultsRepository: UserDefaultsRepository
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        authRepository: AuthManager,
        userRepository: UserRepository,
        messagingManager: MessagingManager,
        defaultsRepository: UserDefaultsRepository
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.messagingManager = messagingManager
        self.defaultsRepository = defaultsRepository
        
        messagingManager.tokenReceivedPublisher
            .sink { _ in 
                Task {
                    try await self.updateNotificationToken()
                }
            }
            .store(in: &cancellables)
    }
    
    static let shared = UserService(
        authRepository: AuthManager(),
        userRepository: UserRepository.shared,
        messagingManager: MessagingManager.shared,
        defaultsRepository: UserDefaultsRepository()
    )
    
    func getUserOnboardingCompleted() -> Bool {
        return defaultsRepository.get(.onboardingCompleted) ?? false
    }
    
    func setUserOnboardingCompleted(_ value: Bool) {
        defaultsRepository.write(.onboardingCompleted, value)
    }
    
    func getCurrentUser() async throws -> User {
        guard let userId = try await authRepository.login() else {
            throw UserServiceError.userIdInvalid
        }
        
        return try await getUserFromRemote(id: userId)
    }
    
    private func getUserFromRemote(id: String) async throws -> User {
        try await userRepository.getUser(id: id)
    }
    
    func createNewUser(nickname: String = "", contactInfo: String = "팀즈로 연락해주세요") async throws -> User {
        do {
            guard let id = try await authRepository.login() else {
                throw UserServiceError.userIdInvalid
            }
            
            try await setUserToRemote(User(id: id, nickname: nickname, contactInfo: contactInfo))
            setUserOnboardingCompleted(true)
            return User(id: id, nickname: nickname, contactInfo: contactInfo)
        } catch let error as UserServiceError {
            throw error
        } catch {
            throw UserServiceError.repositoryError(error)
        }
    }
    
    func updateUser(nickname: String, contactInfo: String) async throws -> User {
        do {
            guard let id = try await authRepository.login() else {
                throw UserServiceError.userIdInvalid
            }
            
            try await setUserToRemote(User(id: id, nickname: nickname, contactInfo: contactInfo))
            return User(id: id, nickname: nickname, contactInfo: contactInfo)
        } catch let error as UserServiceError {
            throw error
        } catch {
            throw UserServiceError.repositoryError(error)
        }
    }
    
    func updateNotificationToken() async throws {
        do {
            guard let id = try await authRepository.login() else {
                throw UserServiceError.userIdInvalid
            }
            
            let token = try await messagingManager.getToken()
            
            try await userRepository.setUserToken(userId: id, token: token)
        } catch let error as UserServiceError {
            throw error
        } catch {
            throw UserServiceError.repositoryError(error)
        }
    }
    
    func signOut() throws {
        do {
            try authRepository.logout()
            defaultsRepository.write(.onboardingCompleted, false)
        } catch let error as UserServiceError {
            throw error
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
        case userNotFound
    }
}
