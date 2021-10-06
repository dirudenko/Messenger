//
//  ChatViewController.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
  
  var isNewConversation = false
  let otherUserEmail: String
  
  private let presenter: ChatViewPresenterProtocol
  
  private var sender: Sender? {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
    let safeEmail = presenter.databaseService.safeEmail(from: email)
    let sender = Sender(senderId: safeEmail,
                        displayName: "Я",
                        photoURL: "")
    return sender
  }
  
  init(presenter: ChatViewPresenterProtocol, email: String) {
    self.presenter = presenter
    self.otherUserEmail = email
    super.init(nibName: nil, bundle: nil)
    if let id = presenter.conversationID {
      presenter.listenForMessages(id: id)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    messageInputBar.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    messageInputBar.inputTextView.becomeFirstResponder()
  }
}
//MARK: - Private func
extension ChatViewController {
  private func createMessageId() -> String? {
    let dateString = dateFormatter(from: Date())
    guard let currentUserMail = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
    let safeEmail = presenter.databaseService.safeEmail(from: currentUserMail)
    let newIdentifier = "\(otherUserEmail)_\(safeEmail)_\(dateString)"
    return newIdentifier
  }
  
  private func dateFormatter(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .long
    formatter.locale = .current
    let stringDate = formatter.string(from: date)
    return stringDate
  }
}

//MARK: - DataSource, Delegate
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
  func currentSender() -> SenderType {
    if let sender = sender {
      return sender
    } else {
      fatalError("sender is nil")
    }
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return presenter.messages[indexPath.section]
  }
  
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return presenter.messages.count
  }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
    let sender = sender,
    let messageId = createMessageId() else { return }
    let message = Message(sender: sender,
                          messageId: messageId,
                          sentDate: Date(),
                          kind: .text(text))
    // send message
    if isNewConversation {
      //create conv
      
      
      presenter.databaseService.createNewConversation(with: otherUserEmail,
                                                      name: self.title ?? "Пользователь",
                                                      firstMessage: message) { success in
        if success {
          print("message send")
          self.isNewConversation = false
        } else {
          print("message NOT send")

        }
      }
    } else {
      guard let conversationID = presenter.conversationID,
      let name = self.title else { return }
      presenter.databaseService.sendMessage(to: conversationID,
                                            otherUserEmail: otherUserEmail,
                                            name: name,
                                            newMessage: message) { success in
        if success {
          print("message send")
        } else {
          print("message NOT send")
        }
      }
    }
  }
}

//MARK: - PresenterProtocol
extension ChatViewController: ChatViewProtocol {
  func successGetMessages() {
    DispatchQueue.main.async {
      self.messagesCollectionView.reloadData()
    }
  }
}
