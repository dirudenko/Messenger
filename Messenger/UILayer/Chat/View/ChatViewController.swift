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
  
  private var messages = [Message]()
  private let presenter: ChatViewPresenterProtocol
  
  private var sender: Sender? {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
    let sender = Sender(senderId: email,
           displayName: "Test",
           photoURL: "")
    return sender
  }
  
  init(presenter: ChatViewPresenterProtocol, email: String) {
    self.presenter = presenter
    self.otherUserEmail = email
    super.init(nibName: nil, bundle: nil)
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
    return Sender(senderId: "", displayName: "", photoURL: "")
    }
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
  
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
    let sender = sender,
    let messageId = createMessageId() else { return }
    // send message
    if isNewConversation {
      //create conv
      
      let message = Message(sender: sender,
                            messageId: messageId,
                            sentDate: Date(),
                            kind: .text(text))
      presenter.databaseService.createNewConversation(with: otherUserEmail,
                                                      firstMessage: message) { success in
        if success {
          print("text send")
        } else {
          print("text NOT send")

        }
      }
    } else {
      //append conv
    }
  }
}

//MARK: - PresenterProtocol
extension ChatViewController: ChatViewProtocol {
  
}
