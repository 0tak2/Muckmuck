//
//  MuckTag.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

struct MuckTag: Hashable {
    let id: UUID
    let region: MuckRegion
    let createdBy: User
    let createdAt: Date
    let availableUntil: Date
    let type: MuckType
    let reactions: [MuckReaction]
    let isDeleted: Bool
    
    init(id: UUID, region: MuckRegion, createdBy: User, createdAt: Date, availableUntil: Date, type: MuckType, reactions: [MuckReaction], isDeleted: Bool = false) {
        self.id = id
        self.region = region
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.availableUntil = availableUntil
        self.type = type
        self.reactions = reactions
        self.isDeleted = isDeleted
    }
    
    static let dummyData: [MuckTag] = [
        .init(
            id: UUID(),
            region: .hoyja,
            createdBy: User.dummyUserBob,
            createdAt: Date(),
            availableUntil: Date(),
            type: .bob,
            reactions: [
                .init(id: UUID(), createdBy: User.dummyUserJoid, createdAt: Date()),
                .init(id: UUID(), createdBy: User.dummyUserLuke, createdAt: Date())
            ]
        ),
        .init(
            id: UUID(),
            region: .daeii,
            createdBy: User.dummyUserJoid,
            createdAt: Date(),
            availableUntil: Date(),
            type: .drink,
            reactions: [
                .init(id: UUID(), createdBy: User.dummyUserBob, createdAt: Date())
            ]
        ),
        .init(
            id: UUID(),
            region: .ugang,
            createdBy: User.dummyUserLuke,
            createdAt: Date(),
            availableUntil: Date(),
            type: .cafe,
            reactions: [
                .init(id: UUID(), createdBy: User.dummyUserJoid, createdAt: Date()),
                .init(id: UUID(), createdBy: User.dummyUserBob, createdAt: Date())
            ]
        )
    ]
}
