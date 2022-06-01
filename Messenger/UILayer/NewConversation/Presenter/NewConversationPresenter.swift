//
//  NewConversationPresenter.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit

protocol NewConversationViewProtocol: AnyObject {
  func updateUI(with results: [SearchResult])
}

protocol NewConversationViewPresenterProtocol: AnyObject {
  func searchUsers(query: String)
}

class NewConversationPresenter: NewConversationViewPresenterProtocol {
  
  weak var view: (UIViewController & NewConversationViewProtocol)?
  // var complition: (([String : String]) -> (Void))?
  
  private var users = [[String: String]]()
  private var hasFetched = false
  
  let databaseService: DatabaseServiceProtocol
  let storageService: StorageServiceProtocol
  
  init(databaseService: DatabaseServiceProtocol, storageService: StorageServiceProtocol) {
    self.databaseService = databaseService
    self.storageService = storageService
  }
  
  func searchUsers(query: String) {
    if hasFetched {
      
    } else {
      databaseService.getAllUsers { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .success(let usersCollection):
          self.hasFetched = true
          self.users = usersCollection
          self.filterUsers(with: query)
        case .failure(let error):
          print(error)
        }
      }
    }
  }
  
  private func filterUsers(with term: String) {
    guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String,
          hasFetched else { return }
    let safeEmail = currentUserEmail.safeEmail
    let results: [SearchResult] = self.users.filter({
      guard let email = $0["email"],
            email != safeEmail else {
              return false
            }
      guard let name = $0["name"]?.lowercased() else {
        return false
      }
      return name.hasPrefix(term.lowercased())
    }).compactMap {
      
      guard let email = $0["email"],
            let name = $0["name"] else {
              return nil
            }
      
      return SearchResult(name: name, email: email)
    }
    self.view?.updateUI(with: results)
  }
}
