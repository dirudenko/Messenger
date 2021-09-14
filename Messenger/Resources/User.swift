//
//  User.swift
//  Messenger
//
//  Created by Dmitry on 13.09.2021.
//

import Foundation

struct User {
  let firstName: String
  let lastName: String
  var fullName: String { firstName + lastName }
  let email: String
  let avatarUrl: String?
  var safeEmail: String {
    var safeEmail = email.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    return safeEmail
  }
}
