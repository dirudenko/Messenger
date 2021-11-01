//
//  RegisterPresenter.swift
//  Messenger
//
//  Created by Dmitry on 07.09.2021.
//

import UIKit
import FirebaseAuth

protocol RegisterViewProtocol: AnyObject {
  func successToRegister()
  func alertUser(_ alert: String)
}

protocol RegisterViewPresenterProtocol: AnyObject {
  func viewDidRegister(firstName: String, lastName: String,email: String, password: String, image: UIImage)
}

class RegisterPresenter: RegisterViewPresenterProtocol {
  
  weak var view: (UIViewController & RegisterViewProtocol)?
  let databaseService: DatabaseServiceProtocol
  let storageService: StorageServiceProtocol
  
  init(databaseService: DatabaseServiceProtocol, storageService: StorageServiceProtocol ) {
    self.databaseService = databaseService
    self.storageService = storageService
  }
  
  func viewDidRegister(firstName: String, lastName: String, email: String, password: String, image: UIImage) {
    
    databaseService.didUserExist(email: email) { exist in
      guard !exist else {
        self.view?.alertUser("Пользователь уже существует")
        return
      }
      FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] result, error in
        guard let self = self else { return }
        
        guard result != nil,
              error == nil else {
                self.view?.alertUser(error?.localizedDescription ?? "Error")
                return
              }
        let newUser = User(firstName: firstName,
                           lastName: lastName,
                           email: email )
        UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
        UserDefaults.standard.setValue(email, forKey: "email")

        self.databaseService.addUser(user: newUser, complition: { success in
          if success {
            let fileName = newUser.UserPictureName
            guard let data = image.pngData() else { return }
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
          }
        })
        self.view?.successToRegister()
      })
    }
  }
}


