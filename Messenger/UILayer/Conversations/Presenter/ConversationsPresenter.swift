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
  func openChat()
}

protocol ConversationsViewPresenterProtocol: AnyObject {
  func viewDidAuthorizate()
  func fetchMessages()
  func viewDidSelectChat()
}

class ConversationsPresenter: ConversationsViewPresenterProtocol {
  
  weak var view: (UIViewController & ConversationsViewProtocol)?
  
  func viewDidAuthorizate() {
    if FirebaseAuth.Auth.auth().currentUser == nil {
      view?.sucessAuthorizate()
    }
  }
  
  func fetchMessages() {
    
  }
  
  
  func viewDidSelectChat() {
    view?.openChat()
  }
  
}
