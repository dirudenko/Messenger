//
//  ProfilePresenter.swift
//  Messenger
//
//  Created by Dmitry on 18.09.2021.
//

import Foundation
import FirebaseAuth


protocol ProfileViewProtocol: AnyObject {
  func sucessLogout()
}

protocol ProfileViewPresenterProtocol: AnyObject {
  func viewDidLogout() -> UIViewController
}

class ProfilePresenter: ProfileViewPresenterProtocol {
  weak var view: (UIViewController & ProfileViewProtocol)?
  
  func viewDidLogout()-> UIViewController {
    let alert = UIAlertController(title: "Внимание",
                                  message: "Вы действительно хотитте выйти?",
                                  preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Выйти",
                                  style: .destructive,
                                  handler: { [weak self] _ in
                                    do {
                                      try FirebaseAuth.Auth.auth().signOut()
                                      self?.view?.sucessLogout()
                                    }
                                    catch {
                                      print("Failed to logout")
                                    }
                                  }))
    alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    return alert
  }
  
  
}
