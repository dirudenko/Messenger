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
  func viewDidRegister(firstName: String, lastName: String,email: String, password: String)
}

class RegisterPresenter: RegisterViewPresenterProtocol {
  
  weak var view: (UIViewController & RegisterViewProtocol)?
  let databaseService: DatabaseServiceProtocol
  
  init(databaseService: DatabaseServiceProtocol ) {
    self.databaseService = databaseService
  }
  
  func viewDidRegister(firstName: String, lastName: String, email: String, password: String) {
    FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {[weak self] result, error in
      guard result != nil,
            error == nil else {
        self?.view?.alertUser(error?.localizedDescription ?? "Error")
        return
      }
      self?.databaseService.addUser(user: User(firstName: firstName,
                                               lastName: lastName,
                                               email: email,
                                               avatarUrl: nil))
      self?.view?.success()
    })
  }
}


