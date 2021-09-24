//
//  NewConversationPresenter.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit


protocol NewConversationViewProtocol: AnyObject {

}

protocol NewConversationViewPresenterProtocol: AnyObject {
  
}

class NewConversationPresenter: NewConversationViewPresenterProtocol {
  
  weak var view: (UIViewController & NewConversationViewProtocol)?
  
  
}
