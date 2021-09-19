//
//  LoginPresenter.swift
//  Messenger
//
//  Created by Dmitry on 06.09.2021.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

protocol LoginViewProtocol: AnyObject {
  func login()
  func alertUser(_ alert: String)
}

protocol LoginViewPresenterProtocol: AnyObject {
  func viewDidLogin(email: String, password: String)
  func viewDidRegister()
  func viewGoogleRegister()
}

class LoginPresenter: LoginViewPresenterProtocol {

  let databaseService: DatabaseServiceProtocol
  init(databaseService: DatabaseServiceProtocol ) {
    self.databaseService = databaseService
  }
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
  
  func viewGoogleRegister() {
    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
    
    // Create Google Sign In configuration object.
    let config = GIDConfiguration(clientID: clientID)
    
    // Start the sign in flow!
    GIDSignIn.sharedInstance.signIn(with: config, presenting: view!) { [weak self] user, error in
      
      if let error = error {
        print (error.localizedDescription)
        return
      }
      
      guard let authentication = user?.authentication,
            let idToken = authentication.idToken
      else {
        return
      }
      
      let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                     accessToken: authentication.accessToken)
      guard let email = user?.profile?.email,
            let firstName = user?.profile?.givenName,
            let lastName = user?.profile?.familyName else { return }
      
      FirebaseAuth.Auth.auth().signIn(with: credential) { result, error in
        guard  result != nil, error == nil else { return }
        self?.databaseService.addUser(user: User(firstName: firstName,
                                                 lastName: lastName,
                                                 email: email,
                                                 avatarUrl: nil))
        self?.view?.login()
      }
    }
  }
  
}
