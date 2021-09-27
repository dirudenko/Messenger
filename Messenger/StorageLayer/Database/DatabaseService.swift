//
//  DatabaseService.swift
//  Messenger
//
//  Created by Dmitry on 13.09.2021.
//

import Foundation
import FirebaseDatabase

protocol  DatabaseServiceProtocol {
  func didUserExist(email: String, complition: @escaping ((Bool) -> Void))
  func addUser(user: User, complition: @escaping (Bool) -> Void)
  func getAllUsers(complition: @escaping (Result<[[String: String]], Error>) -> Void)
}


final class DatabaseService: DatabaseServiceProtocol {
  
  private let database = Database.database().reference(withPath: "messenger")
  
}

//MARK: - Account Managment

extension DatabaseService {
  /// проверка на наличие пользователя в БД
  func didUserExist(email: String, complition: @escaping ((Bool) -> Void)) {
    var safeEmail = email.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    
    database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
      guard snapshot.value as? String != nil else {
        complition(false)
        return
      }
      complition(true)
    }
  }
  
   func getAllUsers(complition: @escaping (Result<[[String: String]], Error>) -> Void) {
    database.child("users").observeSingleEvent(of: .value) { snapshot in
      guard let value = snapshot.value as? [[String: String]] else {
        complition(.failure(DatabaseError.failedToFetch))
        return
      }
      complition(.success(value))
    }
  }
  
  /// add new user to database
  func addUser(user: User, complition: @escaping (Bool) -> Void) {
    database.child(user.safeEmail).setValue([
      "first_name": user.firstName,
      "last_name": user.lastName
    ]) { error, _ in
      guard error == nil else  {
        complition(false)
        return
      }
      
      self.database.child("users").observeSingleEvent(of: .value) { snapshot in
        if var usersCollection = snapshot.value as? [[String: String]] {
          let newElement = [
            "name": user.firstName + " " + user.lastName,
            "email": user.safeEmail
          ]
          usersCollection.append(newElement)

          self.database.child("users").setValue(usersCollection) { error, _ in
            guard error == nil else {
              complition(false)
              return
            }
            complition(true)
          }
          
        } else {
          let newCollection: [[String: String]] = [
            [
              "name": user.firstName + " " + user.lastName,
              "email": user.safeEmail
            ]
          ]
          self.database.child("users").setValue(newCollection) { error, _ in
            guard error == nil else {
              complition(false)
              return
            }
            complition(true)
          }
        }
      }
      
      
    }
  }
}
