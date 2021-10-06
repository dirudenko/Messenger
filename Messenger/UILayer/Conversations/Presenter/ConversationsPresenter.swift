//
//  ConversationsPresenter.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit
import FirebaseAuth

protocol ConversationsViewProtocol: AnyObject {
  func sucessAuthorizate()
  func createChat(model: Conversation)
  func successGetConversations()
}

protocol ConversationsViewPresenterProtocol: AnyObject {
  func viewDidAuthorizate()
  func fetchMessages()
  func viewDidSelectChat(with model: Conversation)
  func startListeningConversation()
  var conversations: [Conversation] { get set }
}

class ConversationsPresenter: ConversationsViewPresenterProtocol {
  
  weak var view: (UIViewController & ConversationsViewProtocol)?
  
  let databaseService: DatabaseMessagingProtocol
  let storageService: StorageServiceProtocol
  var conversations = [Conversation]()
  
  init(databaseService: DatabaseMessagingProtocol,
       storageService: StorageServiceProtocol) {
    self.databaseService = databaseService
    self.storageService = storageService
  }
  
  func viewDidAuthorizate() {
    if FirebaseAuth.Auth.auth().currentUser == nil {
      view?.sucessAuthorizate()
    }
  }
  
  func fetchMessages() {
    
  }
  
  func viewDidSelectChat(with model: Conversation) {
    view?.createChat(model: model)
  }
  
  func startListeningConversation() {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
      return
    }
    let safeEmail = databaseService.safeEmail(from: email)
      self.databaseService.getAllConversation(for: safeEmail) { [weak self] result in
      switch result {
      case .success(let conversations):
        guard !conversations.isEmpty else {
          return
        }
        self?.conversations = conversations
        self?.view?.successGetConversations()
      case .failure(let error):
        print("Failed get conv \(error)")
    }
    }
  }
  
}
