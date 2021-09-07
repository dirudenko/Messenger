//
//  RegisterPresenter.swift
//  Messenger
//
//  Created by Dmitry on 07.09.2021.
//

import UIKit
import FirebaseAuth

protocol RegisterViewProtocol: AnyObject {
  func success()
  func alertUser(_ alert: String)
}

protocol RegisterViewPresenterProtocol: AnyObject {
  func viewDidRegister(email: String, password: String)
}

class RegisterPresenter: RegisterViewPresenterProtocol {
  
  weak var view: (UIViewController & RegisterViewProtocol)?
  
  func viewDidRegister(email: String, password: String) {
    
    FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {[weak self] result, error in
      guard let result = result,
            error == nil else {
        self?.view?.alertUser(error?.localizedDescription ?? "Error")
        return
      }
      
      let user = result.user
      print(user)
      self?.view?.success()
    })
  }
  
  
  
  
}

