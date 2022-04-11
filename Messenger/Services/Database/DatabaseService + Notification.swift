//
//  DatabaseService + Notification.swift
//  Messenger
//
//  Created by Dmitry on 17.02.2022.
//

import Foundation

extension DatabaseService: DatabaseNotificationProtocol {

  func receiveToken(for email: String, complition: @escaping (String?) -> Void) {
    var token: String?
    let ref = database.child("\(email)")
    ref.observeSingleEvent(of: .value) { snapshot in
      guard let userNode = snapshot.value as? [String: Any] else {
              complition(nil)
              return
            }
      token = userNode["token"] as? String
      complition(token)
    }
  }
  
  func sendNotification(from name: String, content: String, token: String) {
    networkManager.request(token: token, name: name, content: content) { result, error  in
      if error != nil {
        fatalError()
      }
    }
  }
}
