//
//  DatabaseService.swift
//  Messenger
//
//  Created by Dmitry on 13.09.2021.
//

import Foundation
import FirebaseDatabase
import MessageKit
import CoreMedia
import CoreLocation

protocol DatabaseServiceProtocol {
  func didUserExist(email: String, complition: @escaping ((Bool) -> Void))
  func addUser(user: User, complition: @escaping (Bool) -> Void)
  func getAllUsers(complition: @escaping (Result<[[String: String]], Error>) -> Void)
  func getData(path: String, complition: @escaping (Result<Any, Error>) -> Void)
}

protocol DatabaseMessagingProtocol {
  func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, complition: @escaping (Bool) -> Void)
  func createNewConversationForRecepient(with otherUserEmail: String, name: String, firstMessage: Message, complition: @escaping (Bool) -> Void)
  func getAllConversation(for email: String, complition: @escaping (Result<[Conversation], Error>) -> Void)
  func getAllMessagesForConversation(with id: String, complition: @escaping (Result<[Message], Error>) -> Void)
  func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, complition: @escaping (Bool) -> Void)
  func sendMessageForReceiver(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, complition: @escaping (Bool) -> Void)
  func deleteConversation(conversationID: String, complition: @escaping (Bool) -> Void)
  func converstionExists(with targetEmail: String, complition: @escaping (Result<String, Error>) -> Void)
  func updateUserToken(email: String, complition: @escaping (Bool) -> Void)
}

protocol DatabaseNotificationProtocol {
  
}

final class DatabaseService {
  let database = Database.database().reference()
  let networkManager = NetworkService()
}
// MARK: - public func
extension DatabaseService {
  
   func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, complition: @escaping (Bool) -> Void) {
    
    let messageDate = firstMessage.sentDate
    let dateString = messageDate.dateFormatter()
    var message = ""
    
    switch firstMessage.kind {
    case .text(let messageText):
      message = messageText
    case .attributedText:
      break
    case .photo(let mediaItem):
      if let targetUrl = mediaItem.url?.absoluteString {
        message = targetUrl
      }
    case .video(let mediaItem):
      if let targetUrl = mediaItem.url?.absoluteString {
        message = targetUrl
      }
    case .location(let locationData):
      let location = locationData.location
      message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
    default: break
    }
    
    guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
      complition(false)
      return
    }
    
    let currentUserEmail = myEmail.safeEmail
    
    let collectionMessage: [String: Any] = [
      "id": firstMessage.messageId,
      "type": firstMessage.kind.description,
      "content": message,
      "date": dateString,
      "sender_email": currentUserEmail,
      "is_read": false,
      "name": name
    ]
    
    let value: [String: Any] = [
      "messages": [
        collectionMessage
      ]
    ]
    
    database.child("\(conversationID)").setValue(value) { error, _ in
      guard error == nil else {
        complition(false)
        return
      }
      complition(true)
    }
  }
}
// MARK: - Account Managment

extension DatabaseService: DatabaseServiceProtocol {
  func getData(path: String, complition: @escaping (Result<Any, Error>) -> Void) {
    database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
      guard let value = snapshot.value else {
        complition(.failure(DatabaseError.failedToFetch))
        return
      }
      complition(.success(value))
    }
  }
  
  /// проверка на наличие пользователя в БД
  func didUserExist(email: String, complition: @escaping ((Bool) -> Void)) {
    let safeEmail = email.safeEmail
    database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
      guard snapshot.exists() else {
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
  
  func updateUserToken(email: String, complition: @escaping (Bool) -> Void) {
    guard let token = UserDefaults.standard.object(forKey: "token") as? String else {
      complition(false)
      return
    }
    let ref = database.child("\(email.safeEmail)")
    ref.observeSingleEvent(of: .value) { snapshot in
      guard var userNode = snapshot.value as? [String: Any] else {
              complition(false)
              return
            }
      userNode["token"] = token
      ref.setValue(userNode)
  }
  }
  /// add new user to database
  func addUser(user: User, complition: @escaping (Bool) -> Void) {
    database.child(user.safeEmail).setValue([
      "first_name": user.firstName,
      "last_name": user.lastName
    ]) { error, _ in
      guard error == nil else {
        complition(false)
        return
      }
      
      self.database.child("users").observeSingleEvent(of: .value) { [weak self] snapshot in
        guard let self = self else {
          complition(false)
          return
        }
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
