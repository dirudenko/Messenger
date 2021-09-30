//
//  ChatPresenter.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit
import MessageKit

protocol ChatViewProtocol: AnyObject {

}

protocol ChatViewPresenterProtocol: AnyObject {
  var databaseService: DatabaseMessagingProtocol { get set }

}

class ChatPresenter: ChatViewPresenterProtocol {
  
  weak var view: (MessagesViewController & ChatViewProtocol)?
  
  var databaseService: DatabaseMessagingProtocol
  
  init(databaseService: DatabaseMessagingProtocol) {
    self.databaseService = databaseService
  }
  
  
  
  
}
