//
//  MessagingManager.swift
//  Muckmuck
//
//  Created by 임영택 on 3/23/25.
//

import Foundation
import FirebaseMessaging
import os.log
import Combine

final class MessagingManager: NSObject {
    static let shared = MessagingManager()
    
    private let log = Logger.of("MessagingManager")
    
    let tokenReceivedPublisher = PassthroughSubject<String?, Never>()
    
    override init() {
        super.init()
        
        Messaging.messaging().delegate = self
    }
    
    func getToken() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            Messaging.messaging().token { token, error in
              if let error = error {
                  continuation.resume(throwing: error)
              } else if let token = token {
                  continuation.resume(returning: token)
              }
            }
        }
    }
}

extension MessagingManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        log.info("didReceiveRegistrationToken: \(fcmToken ?? "nil")")
        tokenReceivedPublisher.send(fcmToken)
    }
}
