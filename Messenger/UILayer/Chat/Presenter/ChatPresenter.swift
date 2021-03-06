//
//  ChatPresenter.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit
import MessageKit
import CoreLocation

protocol ChatViewProtocol: AnyObject {
  func successGetMessages(messages: [Message])
  func alertUser(with text: String)
}

protocol ChatViewPresenterProtocol: AnyObject {
  var conversationID: String? { get set }
  func listenForMessages(id: String)
  func createMessageId(for email: String) -> String?
  func createNewConversation(message: Message, with email: String, title: String, complition: @escaping (Bool) -> Void)
  func appendToConversation(message: Message, with email: String, to conversationID: String, name: String)
  func sendPhotoMessage(email: String, conversationID: String?, info: [UIImagePickerController.InfoKey: Any], name: String?, sender: Sender?)
  func sendVideoMessage(email: String, conversationID: String?, info: [UIImagePickerController.InfoKey: Any], name: String?, sender: Sender?)
  func sendLocation(location: Location, email: String, conversationID: String?, name: String?, sender: Sender?)
  func downloadURL(for path: String, image: UIImageView)
}

class ChatPresenter {
  var conversationID: String?
  weak var view: (MessagesViewController & ChatViewProtocol)?
  
  private let databaseService: DatabaseMessagingProtocol
  private let storageService: StorageServiceProtocol
  
  init(databaseService: DatabaseMessagingProtocol, conversationID: String?, storageService: StorageServiceProtocol) {
    self.databaseService = databaseService
    self.conversationID = conversationID
    self.storageService = storageService
  }
}
// MARK: - Protocol functions
extension ChatPresenter: ChatViewPresenterProtocol {
  
  func downloadURL(for path: String, image: UIImageView) {
    storageService.downloadURL(for: path) { result in
      switch result {
      case .success(let url):
        image.sd_setImage(with: url, completed: nil)
      case .failure(let error):
        print(error)
      }
    }
  }
  
  func listenForMessages(id: String) {
    databaseService.getAllMessagesForConversation(with: id) { [weak self] result in
      switch result {
      case .success(let messages):
        guard !messages.isEmpty else {
          return
        }
        self?.view?.successGetMessages(messages: messages)
      case .failure(let error):
        self?.view?.alertUser(with: "???????????? ?????? ???????????????? ??????????????????: \(error)")
        print("Error to get messages: \(error)")
      }
    }
  }
  
  func createMessageId(for email: String) -> String? {
    let dateString = Date().dateFormatter()
    let userEmail = UserDefaults.standard.value(forKey: "email") as? String ?? ""
    let safeEmail = userEmail.safeEmail
    let newIdentifier = "\(email)_\(safeEmail)_\(dateString)"
    return newIdentifier
  }
  
  func createNewConversation(message: Message, with email: String, title: String, complition: @escaping (Bool) -> Void) {
    databaseService.createNewConversation(with: email,
                                          name: title,
                                          firstMessage: message) { [weak self] success in
      if success {
        print("message send")
        complition(true)
      } else {
        self?.view?.alertUser(with: "???????????? ?????? ???????????????? ??????????????????")
        complition(false)
      }
    }
    databaseService.createNewConversationForRecepient(with: email,
                                          name: title,
                                          firstMessage: message) { [weak self] success in
      if success {
        print("message send")
        complition(true)
      } else {
        self?.view?.alertUser(with: "???????????? ?????? ???????????????? ??????????????????")
        complition(false)
      }
    }
  }
  
  func appendToConversation(message: Message, with email: String, to conversationID: String, name: String) {
    databaseService.sendMessage(to: conversationID,
                                otherUserEmail: email,
                                name: name,
                                newMessage: message) { [weak self] success in
      if success {
        print("message send")
      } else {
        print("message NOT send")
        self?.view?.alertUser(with: "???????????? ?????? ???????????????? ??????????????????")
      }
    }
    databaseService.sendMessageForReceiver(to: conversationID,
                                otherUserEmail: email,
                                name: name,
                                newMessage: message) { [weak self] success in
      if success {
        print("message send")
      } else {
        print("message NOT send")
        self?.view?.alertUser(with: "???????????? ?????? ???????????????? ??????????????????")
      }
    }
  }
  
  func sendPhotoMessage(email: String, conversationID: String?, info: [UIImagePickerController.InfoKey: Any], name: String?, sender: Sender?) {
    guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
          let imageData = image.pngData(),
          let messageId = createMessageId(for: email),
          let conversationId = conversationID,
          let name = name,
          let sender = sender else { return }
    
    let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
    storageService.uploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let urlString):
        guard let url = URL(string: urlString),
              let placeholder = UIImage(systemName: "plus") else { return }
        
        let media = Media(url: url,
                          image: nil,
                          placeholderImage: placeholder,
                          size: .zero)
        let message = Message(sender: sender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .photo(media))
        self.databaseService.sendMessage(to: conversationId,
                                         otherUserEmail: email,
                                         name: name,
                                         newMessage: message) { success in
          if success {
            print("Photo sended")
          } else {
            print("Fail to send photo")
            self.view?.alertUser(with: "???????????? ?????? ???????????????? ????????")
          }
        }
        self.databaseService.sendMessageForReceiver(to: conversationId,
                                    otherUserEmail: email,
                                    name: name,
                                    newMessage: message) { [weak self] success in
          if success {
            print("message send")
          } else {
            self?.view?.alertUser(with: "???????????? ?????? ???????????????? ??????????????????")
          }
        }
      case .failure(let error):
        self.view?.alertUser(with: "???????????? ?????? ???????????????? ????????: \(error)")
      }
    }
  }
    
    func sendVideoMessage(email: String, conversationID: String?, info: [UIImagePickerController.InfoKey: Any], name: String?, sender: Sender?) {
      guard let videoUrl = info[.mediaURL] as? URL,
            let messageId = createMessageId(for: email),
            let conversationId = conversationID,
            let name = name,
            let sender = sender else { return }
      
      let fileName = "video_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
      storageService.uploadMessageVideo(with: videoUrl, fileName: fileName) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .success(let urlString):
          guard let url = URL(string: urlString),
                let placeholder = UIImage(systemName: "plus") else { return }
          
          let media = Media(url: url,
                            image: nil,
                            placeholderImage: placeholder,
                            size: .zero)
          let message = Message(sender: sender,
                                messageId: messageId,
                                sentDate: Date(),
                                kind: .video(media))
          self.databaseService.sendMessage(to: conversationId,
                                           otherUserEmail: email,
                                           name: name,
                                           newMessage: message) { success in
            if success {
              print("Video sended")
            } else {
              print("Fail to send video")
              self.view?.alertUser(with: "???????????? ?????? ???????????????? ??????????")
            }
          }
          self.databaseService.sendMessageForReceiver(to: conversationId,
                                      otherUserEmail: email,
                                      name: name,
                                      newMessage: message) { [weak self] success in
            if success {
              print("message send")
            } else {
              self?.view?.alertUser(with: "???????????? ?????? ???????????????? ??????????????????")
            }
          }
        case .failure(let error):
          self.view?.alertUser(with: "???????????? ?????? ???????????????? ??????????: \(error)")
        }
      }
    }
      
  func sendLocation(location: Location, email: String, conversationID: String?, name: String?, sender: Sender?) {
    guard let messageId = createMessageId(for: email),
          let conversationId = conversationID,
          let name = name,
          let sender = sender else { return }
          let message = Message(sender: sender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .location(location))
        databaseService.sendMessage(to: conversationId,
                                         otherUserEmail: email,
                                         name: name,
                                         newMessage: message) { success in
          if success {
            print("Location sended")
          } else {
            print("Fail to send location")
            self.view?.alertUser(with: "???????????? ?????? ???????????????? ????????????????????")
          }
        }
      }
    
}
