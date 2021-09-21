//
//  Message.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import Foundation
import MessageKit

struct Message: MessageType {
  var sender: SenderType
  var messageId: String
  var sentDate: Date
  var kind: MessageKind
}
