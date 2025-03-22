//
//  Logger+of.swift
//  Muckmuck
//
//  Created by 임영택 on 3/22/25.
//

import os.log

extension Logger {
    static func of(_ category: String) -> Logger {
        .init(subsystem: "com.youngtaek.Muckmuck", category: category)
    }
}
