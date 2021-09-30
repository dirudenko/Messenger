//
//  DatabaseService.swift
//  Messenger
//
//  Created by Dmitry on 13.09.2021.
//

import Foundation
import FirebaseDatabase

protocol DatabaseServiceProtocol {
  func didUserExist(email: String, complition: @escaping ((Bool) -> Void))
  func addUser(user: User, complition: @escaping (Bool) -> Void)
  func getAllUsers(complition: @escaping (Result<[[String: String]], Error>) -> Void)
}

protocol DatabaseMessagingProtocol {
  func createNewConversation(with otherUserEmail: String, firstMessage: Message, complition: @escaping (Bool) -> Void)
  func getAllConversation(for email: String, complition: @escaping (Result<String, Error>) -> Void)
  func getAllMessagerForConversation(with id: String, complition: @escaping (Result<String, Error>) -> Void)
  func sendMessage(to conversation: String, message: Message, complition: @escaping (Bool) -> Void)
  func safeEmail(from email: String) -> String

}


final class DatabaseService: DatabaseServiceProtocol {
  private let database = Database.database().reference(withPath: "messenger")
}
//MARK: - private func
extension DatabaseService {
  
  
  private func dateFormatter(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .long
    formatter.locale = .current
    let stringDate = formatter.string(from: date)
    return stringDate
  }
  
  private func finishCreatingConversation(conversationID: String, firstMessage: Message, complition: @escaping (Bool) -> Void) {
    
    let messageDate = firstMessage.sentDate
    let dateString = dateFormatter(from: messageDate)
    var message = ""
    
    switch firstMessage.kind {
    case .text(let messageText):
      message = messageText
    case .attributedText(_):
      break
    case .photo(_):
      break
    case .video(_):
      break
    case .location(_):
      break
    case .emoji(_):
      break
    case .audio(_):
      break
    case .contact(_):
      break
    case .linkPreview(_):
      break
    case .custom(_):
      break
    }
    
    guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
      complition(false)
      return
    }
    
    let currentUserEmail = safeEmail(from: myEmail)
    
    let collectionMessage: [String: Any] = [
      "id": firstMessage.messageId,
      "type": firstMessage.kind.description,
      "content": message,
      "date": dateString,
      "sender_email": currentUserEmail,
      "is_read": false
    
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
//MARK: - Sending Messages

extension DatabaseService: DatabaseMessagingProtocol {
  func safeEmail(from email: String) -> String {
    var safeEmail = email.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    return safeEmail
  }
  
  func createNewConversation(with otherUserEmail: String, firstMessage: Message, complition: @escaping (Bool) -> Void) {
    guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
    let safeEmail = self.safeEmail(from: currentEmail)
    let ref = database.child("\(safeEmail)")
    ref.observeSingleEvent(of: .value) { [weak self] snapshot in
      guard let self = self,
            var userNode = snapshot.value as? [String: Any] else {
        complition(false)
        return
      }
      
      let messageDate = firstMessage.sentDate
      let dateString = self.dateFormatter(from: messageDate)
      var message = ""
      
      switch firstMessage.kind {
      case .text(let messageText):
        message = messageText
      case .attributedText(_):
        break
      case .photo(_):
        break
      case .video(_):
        break
      case .location(_):
        break
      case .emoji(_):
        break
      case .audio(_):
        break
      case .contact(_):
        break
      case .linkPreview(_):
        break
      case .custom(_):
        break
      }
      
      let conversationID = "conversation_\(firstMessage.messageId)"
      
      let newConversationData: [String: Any] = [
        "id": conversationID,
        "other_user_mail": otherUserEmail,
        "latest_message": [
          "date": dateString,
          "message": message,
          "is_read": false
        ]
      ]
      
      
      if var conversations = userNode["conversations"] as? [[String: Any]] {
        conversations.append(newConversationData)
        userNode["conversations"] = conversations
        ref.setValue(userNode) { [weak self] error, _ in
          guard error == nil else {
            complition(false)
            return
          }
          self?.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, complition: complition)
        }
        
      } else {
        userNode["conversations"] = [
          newConversationData
        ]
        ref.setValue(userNode) { [weak self] error, _ in
          guard error == nil else {
            complition(false)
            return
          }
          self?.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, complition: complition)
        }
      }
    }
  }
  
  func getAllConversation(for email: String, complition: @escaping (Result<String, Error>) -> Void) {
    
  }
  
  func getAllMessagerForConversation(with id: String, complition: @escaping (Result<String, Error>) -> Void) {
    
  }
  
  func sendMessage(to conversation: String, message: Message, complition: @escaping (Bool) -> Void) {
    
  }
}
