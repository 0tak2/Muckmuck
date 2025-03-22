//
//  User.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

struct User: Hashable {
    let id: String
    let nickname: String
    let contactInfo: String
    
    static let dummyUserBob: User = .init(
        id: "52a64585-445f-4fae-87fe-4d6e58524e91",
        nickname: "Bob",
        contactInfo: "팀즈로 연락주세요"
    )
    
    static let dummyUserJoid: User = .init(
        id: "3589003f-497a-40b9-86dc-19556c7ac3b1",
        nickname: "Joid",
        contactInfo: "팀즈로 연락주세요"
    )
    
    static let dummyUserLuke: User = .init(
        id: "34e074cf-6a09-42c4-b581-9ab2dec3c162",
        nickname: "Luke",
        contactInfo: "팀즈로 연락주세요"
    )
}
