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
  func getAllConversation(for email: String, complition: @escaping (Result<[Conversation], Error>) -> Void)
  func getAllMessagesForConversation(with id: String, complition: @escaping (Result<[Message], Error>) -> Void)
  func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, complition: @escaping (Bool) -> Void)
  func deleteConversation(conversationID: String, complition: @escaping (Bool) -> Void)
  func converstionExists(with targetEmail: String, complition: @escaping (Result<String, Error>) -> Void)
}

final class DatabaseService {
  private let database = Database.database().reference()
}
// MARK: - private func
extension DatabaseService {
    
  private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, complition: @escaping (Bool) -> Void) {
    
    let messageDate = firstMessage.sentDate
    let dateString = messageDate.dateFormatter()
    var message = ""
    
    switch firstMessage.kind {
    case .text(let messageText):
      message = messageText
    case .attributedText:
      break
    case .photo:
      break
    case .video:
      break
    case .location:
      break
    case .emoji:
      break
    case .audio:
      break
    case .contact:
      break
    case .linkPreview:
      break
    case .custom:
      break
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
// MARK: - Sending Messages

extension DatabaseService: DatabaseMessagingProtocol {
  
  func converstionExists(with targetEmail: String, complition: @escaping (Result<String, Error>) -> Void) {
    let safeRecipientEmail = targetEmail.safeEmail
    guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
    let safeSenderEmail = senderEmail.safeEmail
    
    database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
      guard let collection = snapshot.value as? [[String: Any]] else {
        complition(.failure(DatabaseError.failedToFetch))
        return
      }
      if let conversation = collection.first(where: {
        guard let targetSenderEmail = $0["other_user_email"] as? String else {
          return false
        }
        return safeSenderEmail == targetSenderEmail
        
      }) {
        guard let id  = conversation["id"] as? String else {
          complition(.failure(DatabaseError.failedToFetch))
          return
        }
        complition(.success(id))
        return
      }
    }
    complition(.failure(DatabaseError.failedToFetch))
    return
  }
  
  func deleteConversation(conversationID: String, complition: @escaping (Bool) -> Void) {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
    let safeEmail = email.safeEmail
    let ref = database.child("\(safeEmail)/conversations")
    ref.observeSingleEvent(of: .value) { snapshot in
      if var conversations = snapshot.value as? [[String: Any]] {
        var position = Int()
        
        if let index = conversations.firstIndex(where: {$0["id"] as! String == conversationID}) {
          position = index
          print(position)
        }
        conversations.remove(at: position)
        ref.setValue(conversations) { error, _ in
          guard error == nil else {
            print("Failed to delete conversation")
            complition(false)
            return
          }
          complition(true)
        }
      }
    }
  }
  
  func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, complition: @escaping (Bool) -> Void) {
    guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
          let currentName = UserDefaults.standard.value(forKey: "name") as? String else { return }
    let safeEmail = currentEmail.safeEmail
    let ref = database.child("\(safeEmail)")
    ref.observeSingleEvent(of: .value) { [weak self] snapshot in
      guard let self = self,
            var userNode = snapshot.value as? [String: Any] else {
              complition(false)
              return
            }
      
      let messageDate = firstMessage.sentDate
      let dateString = messageDate.dateFormatter()
      var message = ""
      
      switch firstMessage.kind {
      case .text(let messageText):
        message = messageText
      case .attributedText:
        break
      case .photo:
        break
      case .video:
        break
      case .location:
        break
      case .emoji:
        break
      case .audio:
        break
      case .contact:
        break
      case .linkPreview:
        break
      case .custom:
        break
      }
      
      let conversationID = "conversation_\(firstMessage.messageId)"
      
      let newConversationData: [String: Any] = [
        "id": conversationID,
        "other_user_mail": otherUserEmail,
        "name": name,
        "latest_message": [
          "date": dateString,
          "message": message,
          "is_read": false
        ]
      ]
      
      let recipient_newConversationData: [String: Any] = [
        "id": conversationID,
        "other_user_mail": safeEmail,
        "name": currentName,
        "latest_message": [
          "date": dateString,
          "message": message,
          "is_read": false
        ]
      ]
      // Update recipient user conv
      
      self.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
        if var conversations = snapshot.value as? [[String: Any]] {
          // append
          conversations.append(recipient_newConversationData)
          self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
        } else {
          // create
          self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
        }
      }
      
      // Update current user conv
      if var conversations = userNode["conversations"] as? [[String: Any]] {
        conversations.append(newConversationData)
        userNode["conversations"] = conversations
        ref.setValue(userNode) { [weak self] error, _ in
          guard error == nil else {
            complition(false)
            return
          }
          self?.finishCreatingConversation(name: name,
                                           conversationID: conversationID,
                                           firstMessage: firstMessage,
                                           complition: complition)
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
          self?.finishCreatingConversation(name: name,
                                           conversationID: conversationID,
                                           firstMessage: firstMessage,
                                           complition: complition)
        }
      }
    }
  }
  
  func getAllConversation(for email: String, complition: @escaping (Result<[Conversation], Error>) -> Void) {
    database.child("\(email)/conversations").observe(.value) { snapshot in
      guard let value = snapshot.value as? [[String: Any]] else {
        complition(.failure(DatabaseError.failedToFetch))
        print(snapshot)
        return
      }
      let conversations: [Conversation] = value.compactMap { dictionary in
        guard let conversationID = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let otherUserEmail = dictionary["other_user_mail"] as? String,
              let latestMessage = dictionary["latest_message"] as? [String: Any],
              let date = latestMessage["date"] as? String,
              let message = latestMessage["message"] as? String,
              let isRead = latestMessage["is_read"] as? Bool else {
                return nil
              }
        let latestMessageObject = LatestMessage(date: date,
                                                text: message,
                                                isRead: isRead)
        return Conversation(id: conversationID,
                             name: name,
                             otherUserEmail: otherUserEmail,
                             latestMessage: latestMessageObject)
      }
      complition(.success(conversations))
    }
  }
  
  func getAllMessagesForConversation(with id: String, complition: @escaping (Result<[Message], Error>) -> Void) {
    let dateFormatter = DateFormatter()
    database.child("\(id)/messages").observe(.value) { snapshot in
      guard let value = snapshot.value as? [[String: Any]] else {
        complition(.failure(DatabaseError.failedToFetch))
        return
      }
      let messages: [Message] = value.compactMap { dictionary in
        guard let name = dictionary["name"] as? String,
              let isRead = dictionary["is_read"] as? Bool,
              let messageID = dictionary["id"] as? String,
              let content = dictionary["content"] as? String,
              let senderEmail = dictionary["sender_email"] as? String,
              let type = dictionary["type"] as? String,
              let dateString = dictionary["date"] as? String
        else {
          return nil
        }
        
        var kind: MessageKind?
        if type == "photo" {
          
          guard let imageUrl = URL(string: content),
                let placoholderImageUrl = UIImage(named: "logo") else {
                  return nil
                }
          
          let media = Media(url: imageUrl,
                            image: nil,
                            placeholderImage: placoholderImageUrl,
                            size: CGSize(width: 300, height: 300))
          kind = .photo(media)
        } else { if type == "video" {
          
          guard let videoUrl = URL(string: content),
                let placoholderImageUrl = UIImage(named: "logo") else {
                  return nil
                }
          
          let media = Media(url: videoUrl,
                            image: nil,
                            placeholderImage: placoholderImageUrl,
                            size: CGSize(width: 300, height: 300))
          kind = .video(media)
        } else { if type == "location" {
          let locationComponents = content.components(separatedBy: ",")
          guard  let longitude = Double(locationComponents[0]),
                 let latitude  = Double(locationComponents[1]) else {
                   return nil
                 }
          let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                  size: CGSize(width: 300, height: 300))
          kind = .location(location)
        } else {
            kind = .text(content)
          }
        }
        }
        guard let finalKind = kind else { return nil }
        
        let date = dateFormatter.date(from: dateString)
        let sender = Sender(senderId: senderEmail,
                            displayName: name,
                            photoURL: "")
        
        return Message(sender: sender,
                       messageId: messageID,
                       sentDate: date ?? Date(),
                       kind: finalKind)
      }
      complition(.success(messages))
    }
  }
  
  func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, complition: @escaping (Bool) -> Void) {
    
    guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
      complition(false)
      return
    }
    
    let currentEmail = myEmail.safeEmail
    
    database.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] snapshot in
      guard let self = self,
            var currentMessage = snapshot.value as? [[String: Any]] else {
              complition(false)
              return
            }
      let messageDate = newMessage.sentDate
      let dateString = messageDate.dateFormatter()
      var message = ""
      
      switch newMessage.kind {
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
      case .emoji:
        break
      case .audio:
        break
      case .contact:
        break
      case .linkPreview:
        break
      case .custom:
        break
      }
      
      let newMessageEntry: [String: Any] = [
        "id": newMessage.messageId,
        "type": newMessage.kind.description,
        "content": message,
        "date": dateString,
        "sender_email": currentEmail,
        "is_read": false,
        "name": name
      ]
      currentMessage.append(newMessageEntry)
      
      self.database.child("\(conversation)/messages").setValue(currentMessage) { error, _ in
        guard error == nil else {
          complition(false)
          return
        }
        
        self.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
          var databaseEntryConversations = [[String: Any]]()
          var targetIndex: Int?
          let updatedValue: [String: Any] = [
            "date": dateString,
            "message": message,
            "is_read": false
          ]
          
          if var currrentUserConversations = snapshot.value as? [[String: Any]] {
            var targetConversation: [String: Any]?
            
            if let index = currrentUserConversations.firstIndex(where: {$0["id"] as! String == conversation}) {
              targetConversation = currrentUserConversations[index]
              targetIndex = index
            }
            
            guard let index = targetIndex else {
              complition(false)
              return
            }
            
            if var targetConversation = targetConversation {
              targetConversation["latest_message"] = updatedValue
              currrentUserConversations[index] = targetConversation
              databaseEntryConversations = currrentUserConversations
            } else {
              let newConversationData: [String: Any] = [
                "id": conversation,
                "other_user_mail": otherUserEmail.safeEmail,
                "name": name,
                "latest_message": updatedValue
              ]
              currrentUserConversations.append(newConversationData)
              databaseEntryConversations = currrentUserConversations
            }
          } else {
            databaseEntryConversations = [
              [
                "id": conversation,
                "other_user_mail": otherUserEmail.safeEmail,
                "name": name,
                "latest_message": updatedValue
              ]
            ]
          }
          
          self.database.child("\(currentEmail)/conversations").setValue(databaseEntryConversations) { error, _ in
            guard error == nil else {
              complition(false)
              return
            }
            
            // Update latest message for receiver
            
            self.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
              
              var databaseEntryConversations = [[String: Any]]()
              guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                return
              }
              
              if var otherUserConversations = snapshot.value as? [[String: Any]] {
                var recipient_targetConversation: [String: Any]?
                var recipient_targetIndex: Int?
                
                if let recipient_index = otherUserConversations.firstIndex(where: {$0["id"] as! String == conversation}) {
                  recipient_targetConversation = otherUserConversations[targetIndex!]
                  recipient_targetIndex = recipient_index
                }
                guard let recipient_index = recipient_targetIndex else {
                  complition(false)
                  return
                }
                if var recipient_targetConversation = recipient_targetConversation {
                  recipient_targetConversation["latest_message"] = updatedValue
                  otherUserConversations[recipient_index] = recipient_targetConversation
                  databaseEntryConversations = otherUserConversations
                } else {
                  let newConversationData: [String: Any] = [
                    "id": conversation,
                    "other_user_mail": currentEmail.safeEmail,
                    "name": currentName,
                    "latest_message": updatedValue
                  ]
                  otherUserConversations.append(newConversationData)
                  databaseEntryConversations = otherUserConversations
                }
              } else {
                databaseEntryConversations = [
                  [
                    "id": conversation,
                    "other_user_mail": currentEmail.safeEmail,
                    "name": currentName,
                    "latest_message": updatedValue
                  ]
                ]
              }
              self.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations) { error, _ in
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
  }
}
