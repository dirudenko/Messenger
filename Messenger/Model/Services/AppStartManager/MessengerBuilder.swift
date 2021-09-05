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
    let viewController = LoginViewController()
    let navVC = UINavigationController()
    navVC.viewControllers = [viewController]
    return navVC
  }
  
  static func buildRegisterViewController() -> UIViewController {
    let viewController = RegisterViewController()
    return viewController
  }

}
