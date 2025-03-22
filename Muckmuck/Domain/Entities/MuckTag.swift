//
//  MuckTag.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

struct MuckTag: Hashable {
    let region: MuckRegion
    let createdBy: User
    let createdAt: Date
    let availableUntil: Date
    let type: MuckType
    let reactions: [MuckReaction]
    let isDeleted: Bool = false
    
    static let dummyData: [MuckTag] = [
        .init(
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
