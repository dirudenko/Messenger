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
  static func buildNewConversationViewController() -> UIViewController {
    let databaseService = DatabaseService()
    let storageService = StorageService()
    let presenter = NewConversationPresenter(databaseService: databaseService, storageService: storageService)
    let vc = NewConversationViewController(presenter: presenter)
    presenter.view = vc
    return vc
  }
  
  static func buildTabBar() -> UIViewController {
    let vc = TabBarViewController()
    return vc
  }
  
  static func buildConversationsViewController() -> UIViewController {
    let databaseService = DatabaseService()
    let storageService = StorageService()

    let presenter = ConversationsPresenter(databaseService: databaseService, storageService: storageService)
    let vc = ConversationsViewController(presenter: presenter)
    presenter.view = vc
    return vc
  }
  
  static func buildLoginScreenViewController() -> UIViewController {
    let databaseService = DatabaseService()
    let storageService = StorageService()
    let presenter = LoginPresenter(databaseService: databaseService, storageService: storageService)
    let viewController = LoginViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }
  
  static func buildRegisterViewController() -> UIViewController {
    let databaseService = DatabaseService()
    let storageService = StorageService()
    let presenter = RegisterPresenter(databaseService: databaseService, storageService: storageService)
    let viewController = RegisterViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }

  static func buildProfileViewController() -> UIViewController {
    let storageService = StorageService()
    let presenter = ProfilePresenter(storageService: storageService)
    let viewController = ProfileViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }
  
  static func buildChatViewController(with email: String, conversationID: String?) -> UIViewController {
    let databaseService = DatabaseService()
    let storageService = StorageService()
    let presenter = ChatPresenter(databaseService: databaseService, conversationID: conversationID, storageService: storageService)
    let vc = ChatViewController(presenter: presenter, email: email)
    presenter.view = vc
    return vc
  }
  
  static func buildPhotoViewerViewController(with url: URL) -> UIViewController {
   // let databaseService = DatabaseService()
   // let storageService = StorageService()
    let presenter = PhotoViewerPresenter()
    let vc = PhotoViewerViewController(presenter: presenter, url: url)
    presenter.view = vc
    return vc
  }
}
