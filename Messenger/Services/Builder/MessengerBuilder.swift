//
//  MessengerBuilder.swift
//  Messenger
//
//  Created by Dmitry on 04.09.2021.
//

import UIKit

protocol Builder {
  static func buildTabBar() -> UIViewController
  static func buildValidation() -> UIViewController
  static func buildLoginScreen() -> UIViewController
  static func buildRegisterViewController() -> UIViewController
  static func buildProfileViewController() -> UIViewController
}

class MessengerBuilder: Builder {
  static func buildTabBar() -> UIViewController {
    let vc = TabBarViewController()
    return vc
  }
  
  static func buildValidation() -> UIViewController {
    let vc = StartViewController()
    return vc
  }
  
  
  static func buildLoginScreen() -> UIViewController {
    let presenter = LoginPresenter()
    let viewController = LoginViewController(presenter: presenter)
    presenter.view = viewController
   // let navVC = UINavigationController()
   // navVC.viewControllers = [viewController]
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
  
}
