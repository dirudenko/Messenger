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
  let databaseService: DatabaseServiceProtocol & DatabaseMessagingProtocol
  let storageService: StorageServiceProtocol
  
  init(databaseService: (DatabaseServiceProtocol & DatabaseMessagingProtocol), storageService: StorageServiceProtocol) {
    self.databaseService = databaseService
    self.storageService = storageService
  }
  
  /// Авторизация через приложение
  func viewDidLogin(email: String, password: String) {
    FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] result, error in
      guard let self = self else { return }
      
      guard result != nil,
            error == nil else {
              self.view?.alertUser(error?.localizedDescription ?? "Error")
              return
            }
      let safeEmail = email.safeEmail
      self.databaseService.getData(path: safeEmail) { result in
        switch result {
        case .success(let data):
          guard let userData = data as? [String: Any],
                let firstName = userData["first_name"] as? String,
                let lastName = userData["last_name"] as? String else {
                  return
                }
          UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
          UserDefaults.standard.setValue(email, forKey: "email")
          
        case .failure(let error):
          print("Error in getting user info: \(error)")
        }
      }
      
      self.view?.sucessToLogin()
    })
  }
  
  func viewDidRegister() {
    let viewController = MessengerBuilder.buildRegisterViewController()
    view?.navigationController?.pushViewController(viewController, animated: true)
  }
  
  /// Авторизация через Google
  func viewDidGoogleRegister() {
    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
    
    let config = GIDConfiguration(clientID: clientID)
    
    GIDSignIn.sharedInstance.signIn(with: config, presenting: view!) { [weak self] user, error in
      guard let self = self else { return }
      
      if let error = error {
        print(error.localizedDescription)
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
      UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
      
      self.databaseService.didUserExist(email: email) { exist in
        if exist {
          print("User is exist")
          FirebaseAuth.Auth.auth().signIn(with: credential) { result, error in
            guard  result != nil, error == nil else { return }
            self.view?.sucessToLogin()
          }
        } else {
          print("User is not exist")
          FirebaseAuth.Auth.auth().signIn(with: credential) { result, error in
            guard  result != nil, error == nil else { return }
            let newUser = User(firstName: firstName,
                               lastName: lastName,
                               email: email)
            
            self.databaseService.addUser(user: newUser, complition: { success in
              if success {
                if (user?.profile?.hasImage) != nil {
                  guard let url = user?.profile?.imageURL(withDimension: 200) else { return }
                  URLSession.shared.dataTask(with: url) { data, response, error in
                    
                    if error != nil { return }
                    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return }

                    guard let data  = data else { return }
                    let fileName = newUser.userPictureName
                    self.storageService.uploadProfilePhoto(with: data,
                                                           fileName: fileName) { result in
                      switch result {
                      case .success(let downloadURL):
                        UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                        // print(downloadURL)
                      case .failure(let error):
                        print(error)
                      }
                    }
                  }.resume()
                }
              }
              self.view?.sucessToLogin()
            })
          }
        }
      }
    }
  }
}
