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
  static func buildChatViewController(with email: String, conversationID: String?) -> UIViewController
  static func buildNewConversationViewController() -> UIViewController
  static func buildPhotoViewerViewController(with url: URL) -> UIViewController
}

class MessengerBuilder: Builder {
  
  private static let databaseService = DatabaseService()
  private static let storageService = StorageService()
  
  static func buildNewConversationViewController() -> UIViewController {
    let presenter = NewConversationPresenter(databaseService: databaseService, storageService: storageService)
    let viewController = NewConversationViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }
  
  static func buildTabBar() -> UIViewController {
    let viewController = TabBarViewController()
    viewController.selectedIndex = 0
    return viewController
  }
  
  static func buildConversationsViewController() -> UIViewController {
    let presenter = ConversationsPresenter(databaseService: databaseService, storageService: storageService)
    let viewController = ConversationsViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }
  
  static func buildLoginScreenViewController() -> UIViewController {
    let presenter = LoginPresenter(databaseService: databaseService, storageService: storageService)
    let viewController = LoginViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }
  
  static func buildRegisterViewController() -> UIViewController {
    let presenter = RegisterPresenter(databaseService: databaseService, storageService: storageService)
    let viewController = RegisterViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }

  static func buildProfileViewController() -> UIViewController {
    let presenter = ProfilePresenter(storageService: storageService)
    let viewController = ProfileViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }
  
  static func buildChatViewController(with email: String, conversationID: String?) -> UIViewController {
    let presenter = ChatPresenter(databaseService: databaseService, conversationID: conversationID, storageService: storageService)
    let viewController = ChatViewController(presenter: presenter, email: email)
    presenter.view = viewController
    return viewController
  }
  
  static func buildPhotoViewerViewController(with url: URL) -> UIViewController {
    let presenter = PhotoViewerPresenter()
    let viewController = PhotoViewerViewController(presenter: presenter, url: url)
    presenter.view = viewController
    return viewController
  }
}
