//
//  Sender.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import Foundation
import MessageKit

struct Sender: SenderType {
  var senderId: String
  var displayName: String
  var photoURL: String
}
