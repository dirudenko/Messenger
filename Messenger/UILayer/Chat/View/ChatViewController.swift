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
  
  private let sender = Sender(senderId: "01",
                              displayName: "Test",
                              photoURL: "")
  
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
