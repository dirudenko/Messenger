//
//  ChatPresenter.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit
import MessageKit

protocol ChatViewProtocol: AnyObject {
  func successGetMessages()

}

protocol ChatViewPresenterProtocol: AnyObject {
  var databaseService: DatabaseMessagingProtocol { get set }
  var conversationID: String? { get set }
  var messages: [Message] { get set }
  func listenForMessages(id: String)
}

class ChatPresenter: ChatViewPresenterProtocol {
  var messages = [Message]()
  
  var conversationID: String?
  
  weak var view: (MessagesViewController & ChatViewProtocol)?
  
  var databaseService: DatabaseMessagingProtocol
  
  init(databaseService: DatabaseMessagingProtocol, conversationID: String?) {
    self.databaseService = databaseService
    self.conversationID = conversationID
  }
  
  func listenForMessages(id: String) {
    databaseService.getAllMessagerForConversation(with: id) { [weak self] result in
      switch result {
      case .success(let messages):
        guard !messages.isEmpty else {
          return
        }
        self?.messages = messages
        self?.view?.successGetMessages()
      case .failure(let error):
        print("Error to get messages: \(error)")
      }
    }
  }

  
  
}
