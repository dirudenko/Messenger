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
  func sucessToLogin()
  func alertUser(_ alert: String)
}

protocol LoginViewPresenterProtocol: AnyObject {
  func viewDidLogin(email: String, password: String)
  func viewDidRegister()
  func viewDidGoogleRegister()
}

class LoginPresenter: LoginViewPresenterProtocol {
  
  weak var view: (UIViewController & LoginViewProtocol)?
  let databaseService: DatabaseServiceProtocol
  let storageService: StorageServiceProtocol
  
  init(databaseService: DatabaseServiceProtocol, storageService: StorageServiceProtocol) {
    self.databaseService = databaseService
    self.storageService = storageService
  }
  
  /// Авторизация через приложение
  func viewDidLogin(email: String, password: String) {
    FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] result , error in
      guard let self = self else { return }
      
      guard let result = result,
            error == nil else {
              self.view?.alertUser(error?.localizedDescription ?? "Error")
              return
            }
      let user = result.user
      UserDefaults.standard.set(email, forKey: "email")
      
      self.view?.sucessToLogin()
    })
  }
  
  func viewDidRegister() {
    let vc = MessengerBuilder.buildRegisterViewController()
    view?.navigationController?.pushViewController(vc, animated: true)
  }
  
  /// Авторизация через Google
  func viewDidGoogleRegister() {
    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
    
    let config = GIDConfiguration(clientID: clientID)
    
    GIDSignIn.sharedInstance.signIn(with: config, presenting: view!) { [weak self] user, error in
      guard let self = self else { return }
      
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
      
      UserDefaults.standard.set(email, forKey: "email")

      FirebaseAuth.Auth.auth().signIn(with: credential) { result, error in
        guard  result != nil, error == nil else { return }
        let newUser = User(firstName: firstName,
                           lastName: lastName,
                           email: email)
        
        self.databaseService.addUser(user: newUser, complition: { success in
          if success {
            if (user?.profile?.hasImage) != nil {
              guard let url = user?.profile?.imageURL(withDimension: 200) else { return }
              URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data  = data else { return }
                let fileName = newUser.UserPictureName
                self.storageService.uploadProfilePhoto(with: data,
                                                       fileName: fileName) { result in
                  switch result {
                  case .success(let downloadURL):
                    UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                    print(downloadURL)
                  case .failure(let error):
                    print(error)
                  }
                }
              }.resume()
            }
          }
        })
        self.view?.sucessToLogin()
      }
    }
  }
  
}
