//
//  MessengerBuilder.swift
//  Messenger
//
//  Created by Dmitry on 04.09.2021.
//

import UIKit

protocol Builder {
  static func createLoginScreen() -> UIViewController
  static func buildRegisterViewController() -> UIViewController
}


class MessengerBuilder: Builder {
  
  static func createLoginScreen() -> UIViewController {
    let presenter = LoginPresenter()
    let viewController = LoginViewController(presenter: presenter)
    presenter.view = viewController
    let navVC = UINavigationController()
    navVC.viewControllers = [viewController]
    return navVC
  }
  
  static func buildRegisterViewController() -> UIViewController {
    let presenter = RegisterPresenter()
    let viewController = RegisterViewController(presenter: presenter)
    presenter.view = viewController
    return viewController
  }

}
