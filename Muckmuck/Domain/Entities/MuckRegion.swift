//
//  MuckRegion.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import Foundation

enum MuckRegion: Hashable, CaseIterable {
    static var allCases: [MuckRegion] = [.hoyja, .ugang, .daejam, .daeii, .zugdo, .other("기타")]
    
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
    
    static func from(localizedString: String) -> MuckRegion {
        switch localizedString {
        case "효자":
            return .hoyja
        case "유강":
            return .ugang
        case "대잠":
            return .daejam
        case "대이":
            return .daeii
        case "죽도":
            return .zugdo
        default:
            return .other(localizedString)
        }
    }
}
