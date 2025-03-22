//
//  MuckType.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

enum MuckType: String, Hashable {
    case bob = "bob"
    case cafe = "cafe"
    case drink = "drink"
    
    func getEmoji() -> String {
        switch self {
        case .bob:
            return "🍚"
        case .cafe:
            return "☕️"
        case .drink:
            return "🍺"
        }
    }
    
    func getLocalizedString() -> String {
        switch self {
        case .bob:
            return "밥"
        case .cafe:
            return "카페"
        case .drink:
            return "술"
        }
    }
}
