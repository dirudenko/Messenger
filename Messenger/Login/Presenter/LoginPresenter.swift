//
//  LoginPresenter.swift
//  Messenger
//
//  Created by Dmitry on 06.09.2021.
//

import UIKit
import FirebaseAuth

protocol LoginViewProtocol: AnyObject {
  func login()
  func alertUser(_ alert: String)
}

protocol LoginViewPresenterProtocol: AnyObject {
  func viewDidLogin(email: String, password: String)
  func viewDidRegister()
}

class LoginPresenter: LoginViewPresenterProtocol {
  
  weak var view: (UIViewController & LoginViewProtocol)?
  
  func viewDidLogin(email: String, password: String) {
    FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] result , error in
      guard let result = result,
            error == nil else {
        self?.view?.alertUser(error?.localizedDescription ?? "Error")
        return
      }
      let user = result.user
      print(user)
      self?.view?.login()
    })
  }
  
  func viewDidRegister() {
    let vc = MessengerBuilder.buildRegisterViewController()
    view?.navigationController?.pushViewController(vc, animated: true)
  }
  
  
}
