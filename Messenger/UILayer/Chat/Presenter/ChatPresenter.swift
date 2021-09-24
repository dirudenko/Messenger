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
  
}

class ChatPresenter: ChatViewPresenterProtocol {
  
  weak var view: (MessagesViewController & ChatViewProtocol)?
  
  
}
