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
}
