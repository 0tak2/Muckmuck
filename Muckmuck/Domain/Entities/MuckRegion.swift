//
//  MuckRegion.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

enum MuckRegion {
    case hoyja
    case ugang
    case daejam
    case daeii
    case zugdo
    case other(String)
    
    func getLocalizedString() -> String {
        switch self {
        case .hoyja:
            return "효자"
        case .ugang:
            return "유강"
        case .daejam:
            return "대잠"
        case .daeii:
            return "대이"
        case .zugdo:
            return "죽도"
        case .other(let name):
            return name
        }
    }
}
