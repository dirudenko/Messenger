//
//  ProfilePresenter.swift
//  Messenger
//
//  Created by Dmitry on 18.09.2021.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

protocol ProfileViewProtocol: AnyObject {
  func sucessLogout()
}

protocol ProfileViewPresenterProtocol: AnyObject {
  func viewDidLogout() -> UIViewController
  func safeEmail(for email: String) -> String
  func downloadURL(for path: String, image: UIImageView)
}

class ProfilePresenter: ProfileViewPresenterProtocol {
  
  weak var view: (UIViewController & ProfileViewProtocol)?
  let storageService: StorageServiceProtocol
  
  init(storageService: StorageServiceProtocol) {
    self.storageService = storageService
  }
  
  func viewDidLogout() -> UIViewController {
    let alert = UIAlertController(title: "Внимание",
                                  message: "Вы действительно хотите выйти?",
                                  preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Выйти",
                                  style: .destructive,
                                  handler: { [weak self] _ in
      guard let self = self else { return }
      do {
        /// Выход из Google
        GIDSignIn.sharedInstance.signOut()
        
        try FirebaseAuth.Auth.auth().signOut()
        self.view?.sucessLogout()
      }
      catch {
        print("Failed to logout")
      }
    }))
    alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    return alert
  }
  
  func safeEmail(for email: String) -> String {
    return storageService.safeEmail(email: email)
  }
  
  func downloadURL(for path: String, image: UIImageView) {
    storageService.downloadURL(for: path) { result in
      switch result {
      case .success(let url):
        self.downloadImage(imageView: image, url: url)
      case .failure(let error):
        print(error)
      }
    }
  }
  
  private func downloadImage(imageView: UIImageView, url: URL) {
    URLSession.shared.dataTask(with: url) { data, _, error in
      guard let data = data, error == nil else {
        return
      }
      DispatchQueue.main.async {
        let image = UIImage(data: data)
        imageView.image = image
      }
    }.resume()
  }
  
}
