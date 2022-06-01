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

extension MessageKind {
  var description: String {
    switch self {
    case .text:
      return "text"
    case .attributedText:
      return "attributed_text"
    case .photo:
      return "photo"
    case .video:
      return "video"
    case .location:
      return "location"
    case .emoji:
      return "emoji"
    case .audio:
      return "audio"
    case .contact:
      return "contact"
    case .linkPreview:
      return "link_preview"
    case .custom:
      return "custom"
    }
  }
}
