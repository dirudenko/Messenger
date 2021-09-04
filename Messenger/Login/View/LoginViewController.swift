//
//  LoginViewController.swift
//  Messenger
//
//  Created by Dmitry on 04.09.2021.
//

import UIKit

class LoginViewController: UIViewController {

//  private var loginView: LoginView {
//    return self.view as! LoginView
//  }
//
//  override func loadView() {
//      super.loadView()
//      self.view = LoginView()
//  }
  
  private let loginView = LoginView()
  
    override func viewDidLoad() {
        super.viewDidLoad()

      self.view = loginView
      
    }
}
