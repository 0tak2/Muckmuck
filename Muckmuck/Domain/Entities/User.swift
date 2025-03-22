//
//  User.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

struct User {
    let id: UUID
    let nickname: String
    let contact: String
    
    static let dummyUserBob: User = .init(
        id: UUID(uuidString: "52a64585-445f-4fae-87fe-4d6e58524e91")!,
        nickname: "Bob",
        contact: "팀즈로 연락주세요"
    )
    
    static let dummyUserJoid: User = .init(
        id: UUID(uuidString: "3589003f-497a-40b9-86dc-19556c7ac3b1")!,
        nickname: "Joid",
        contact: "팀즈로 연락주세요"
    )
}
