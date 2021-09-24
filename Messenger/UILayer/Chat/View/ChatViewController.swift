//
//  ChatViewController.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {
  
  private var messages = [Message]()
  private let presenter: ChatViewPresenterProtocol
  
  private let sender = Sender(senderId: "01",
                              displayName: "Test",
                              photoURL: "")
  
  init(presenter: ChatViewPresenterProtocol) {
    self.presenter = presenter
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
    messages.append(Message(sender: sender,
                            messageId: "1",
                            sentDate: Date(),
                            kind: .text("Hello World")))
  }
}
//MARK: - DataSource, Delegate
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
  func currentSender() -> SenderType {
    return sender
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
  
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
}
//MARK: - PresenterProtocol
extension ChatViewController: ChatViewProtocol {
  
}
