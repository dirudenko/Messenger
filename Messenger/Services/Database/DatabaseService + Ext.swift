//
//  DatabaseService + Ext.swift
//  Messenger
//
//  Created by Dmitry on 16.02.2022.
//

import UIKit
import MessageKit
import CoreLocation

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
        // swiftlint:disable force_cast
        if let index = conversations.firstIndex(where: {$0["id"] as! String == conversationID}) {
          // swiftlint:enable force_cast
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
    guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
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
  
  private func configureDataForUpdatingDatabase(with otherUserEmail: String, name: String, firstMessage: Message, complition: @escaping ([String: Any]?) -> Void) {
    guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
          let currentName = UserDefaults.standard.value(forKey: "name") as? String else { return }
    let safeEmail = currentEmail.safeEmail
    
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
      
      let conversationID = "conversation_\(firstMessage.messageId)"
      
      let newConversationData: [String: Any] = [
        "id": conversationID,
        "other_user_mail": safeEmail,
        "name": currentName,
        "latest_message": [
          "date": dateString,
          "message": message,
          "is_read": false
        ]
      ]
      complition(newConversationData)
  }
  
  func createNewConversationForRecepient(with otherUserEmail: String, name: String, firstMessage: Message, complition: @escaping (Bool) -> Void) {
    self.configureDataForUpdatingDatabase(with: otherUserEmail, name: name, firstMessage: firstMessage) { result in
      guard let newConversationData = result else { complition(false)
        return
      }
      self.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
        if var conversations = snapshot.value as? [[String: Any]] {
          // append
          conversations.append(newConversationData)
          self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
        } else {
          // create
          self?.database.child("\(otherUserEmail)/conversations").setValue([newConversationData])
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
              //let isRead = dictionary["is_read"] as? Bool,
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
  
  private func prepareForSendMessage( conversation: String, otherUserEmail: String, name: String, newMessage: Message, complition: @escaping ([[String: Any]]?) -> Void) {
    database.child("\(conversation)/messages").observeSingleEvent(of: .value) { snapshot in
      guard var currentMessage = snapshot.value as? [[String: Any]],
            let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
              complition(nil)
              return
            }
      let messageDate = newMessage.sentDate
      let dateString = messageDate.dateFormatter()
      var message = ""
      let currentEmail = myEmail.safeEmail
      
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
      default: break
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
      complition(currentMessage)
    }
  }
  
  func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, complition: @escaping (Bool) -> Void) {
    guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
      complition(false)
      return
    }
    let currentEmail = myEmail.safeEmail
    
    prepareForSendMessage(conversation: conversation, otherUserEmail: otherUserEmail, name: name, newMessage: newMessage) { result in
      guard let currentMessage = result else {
        complition(false)
        return
      }
      self.database.child("\(conversation)/messages").setValue(currentMessage) { error, _ in
        guard error == nil else {
          complition(false)
          return
        }
        self.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
          var databaseEntryConversations = [[String: Any]]()
          var targetIndex: Int?
          let updatedValue: [String: Any] = [
            "date": currentMessage.last?["date"] ?? "",
            "message": currentMessage.last?["content"] ?? "",
            "is_read": false
          ]
          
          if var currrentUserConversations = snapshot.value as? [[String: Any]] {
            var targetConversation: [String: Any]?
            // swiftlint:disable force_cast
            if let index = currrentUserConversations.firstIndex(where: {$0["id"] as! String == conversation}) {
              // swiftlint:enable force_cast
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
            
          }
        }
      }
    }
  }
  
  func sendMessageForReceiver(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, complition: @escaping (Bool) -> Void) {
    
    guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
      complition(false)
      return
    }
    let currentEmail = myEmail.safeEmail
    
    prepareForSendMessage(conversation: conversation, otherUserEmail: otherUserEmail, name: name, newMessage: newMessage) { result in
      guard let currentMessage = result else {
        complition(false)
        return
      }
      self.database.child("\(conversation)/messages").setValue(currentMessage) { error, _ in
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
          let updatedValue: [String: Any] = [
            "date": currentMessage.last?["date"] ?? "",
            "message": currentMessage.last?["content"] ?? "",
            "is_read": false
          ]
          
          if var otherUserConversations = snapshot.value as? [[String: Any]] {
            var targetConversation: [String: Any]?
            var targetIndex: Int?
            // swiftlint:disable force_cast
            if let index = otherUserConversations.firstIndex(where: {$0["id"] as! String == conversation}) {
              // swiftlint:enable force_cast
              targetIndex = index
              targetConversation = otherUserConversations[targetIndex!]
            }
            guard let index = targetIndex else {
              complition(false)
              return
            }
            if var targetConversation = targetConversation {
              targetConversation["latest_message"] = updatedValue
              otherUserConversations[index] = targetConversation
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
