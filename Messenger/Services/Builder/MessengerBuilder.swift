//
//  MessengerBuilder.swift
//  Messenger
//
//  Created by Dmitry on 04.09.2021.
//

import UIKit

protocol Builder {
  static func buildTabBar() -> UIViewController
  static func buildConversationsViewController() -> UIViewController
  static func buildLoginScreenViewController() -> UIViewController
  static func buildRegisterViewController() -> UIViewController
  static func buildProfileViewController() -> UIViewController
  static func buildChatViewController() -> UIViewController
  static func buildNewConversationViewController() -> UIViewController

}

class MessengerBuilder: Builder {
  static func buildNewConversationViewController() -> UIViewController {
    let presenter = NewConversationPresenter()
    let vc = NewConversationViewController(presenter: presenter)
    presenter.view = vc
    return vc
  }
  
  static func buildTabBar() -> UIViewController {
    let vc = TabBarViewController()
    return vc
  }
  
  static func buildConversationsViewController() -> UIViewController {
    let presenter = ConversationsPresenter()
    let vc = ConversationsViewController(presenter: presenter)
    presenter.view = vc
    return vc
  }
  
  static func buildLoginScreenViewController() -> UIViewController {
    let databaseService = DatabaseService()
    let presenter = LoginPresenter(databaseService: databaseService)
    let viewController = LoginViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }
  
  static func buildRegisterViewController() -> UIViewController {
    let databaseService = DatabaseService()
    let presenter = RegisterPresenter(databaseService: databaseService)
    let viewController = RegisterViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }

  static func buildProfileViewController() -> UIViewController {
    let presenter = ProfilePresenter()
    let viewController = ProfileViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }
  
  static func buildChatViewController() -> UIViewController {
    let vc = ChatViewController()
    return vc
  }
}
