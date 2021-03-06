//
//  ConversationsPresenter.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit
import FirebaseAuth
import SwiftUI

protocol ConversationsViewProtocol: AnyObject {
  func unableToAuthorizate()
  func successGetConversations(conversations: [Conversation])
}

protocol ConversationsViewPresenterProtocol: AnyObject {
  func viewDidAuthorizate() -> Bool
  func startListeningConversation()
  func deleteConversation(conversationID: String, complition: @escaping (Bool) -> Void)
  func converstionExists(email: String, complition: @escaping (Result<String, Error>) -> Void)
}

class ConversationsPresenter: ConversationsViewPresenterProtocol {
  weak var view: (UIViewController & ConversationsViewProtocol)?
  
  let databaseService: DatabaseMessagingProtocol
  let storageService: StorageServiceProtocol
  
  init(databaseService: DatabaseMessagingProtocol,
       storageService: StorageServiceProtocol) {
    self.databaseService = databaseService
    self.storageService = storageService
  }
  
  func viewDidAuthorizate() -> Bool {
    if FirebaseAuth.Auth.auth().currentUser == nil {
      view?.unableToAuthorizate()
      return false
    } else {
      return true
    }
  }
  
  func converstionExists(email: String, complition: @escaping (Result<String, Error>) -> Void) {
    databaseService.converstionExists(with: email) { result in
      switch result {
      case .success(let conversationId):
        complition(.success(conversationId))
      case .failure:
        complition(.failure(DatabaseError.failedToFetch))
      }
    }
  }
  
  func startListeningConversation() {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
      return
    }
    let safeEmail = email.safeEmail
    databaseService.getAllConversation(for: safeEmail) { [weak self] result in
      switch result {
      case .success(let conversations):
        guard !conversations.isEmpty else {
          return
        }
        self?.view?.successGetConversations(conversations: conversations)
      case .failure(let error):
        print("Failed get conv \(error)")
      }
    }
  }
  func deleteConversation(conversationID: String, complition: @escaping (Bool) -> Void) {
    databaseService.deleteConversation(conversationID: conversationID) { success in
      if success {
        complition(true)
      } else {
        complition(false)
      }
    }
  }
}
