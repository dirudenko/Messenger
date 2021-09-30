//
//  NewConversationPresenter.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit


protocol NewConversationViewProtocol: AnyObject {
  func updateUI()
}

protocol NewConversationViewPresenterProtocol: AnyObject {
  func searchUsers(query: String)
  var results: [[String: String]] { get set }
}

class NewConversationPresenter: NewConversationViewPresenterProtocol {
  
  var results = [[String: String]]()
  weak var view: (UIViewController & NewConversationViewProtocol)?
  var complition: (([String : String]) -> (Void))?
  
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
    guard hasFetched else { return }
    let results: [[String: String]] = self.users.filter ({
      guard let name = $0["name"]?.lowercased() else {
        return false
      }
      return name.hasPrefix(term.lowercased())
    })
    self.results = results
    self.view?.updateUI()
  }
}
