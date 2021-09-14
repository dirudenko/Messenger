//
//  MessengerBuilder.swift
//  Messenger
//
//  Created by Dmitry on 04.09.2021.
//

import UIKit

protocol Builder {
  static func buildValidation() -> UIViewController
  static func buildLoginScreen() -> UIViewController
  static func buildRegisterViewController() -> UIViewController
}

class MessengerBuilder: Builder {
  static func buildValidation() -> UIViewController {
    let vc = StartViewController()
    return vc
  }
  
  
  static func buildLoginScreen() -> UIViewController {
    let presenter = LoginPresenter()
    let viewController = LoginViewController(presenter: presenter)
    presenter.view = viewController
    let navVC = UINavigationController()
    navVC.viewControllers = [viewController]
    return navVC
  }
  
  static func buildRegisterViewController() -> UIViewController {
    let databaseService = DatabaseService()
    let presenter = RegisterPresenter(databaseService: databaseService)
    let viewController = RegisterViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }

}
