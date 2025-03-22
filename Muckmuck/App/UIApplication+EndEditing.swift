//
//  AppDelegate+.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
