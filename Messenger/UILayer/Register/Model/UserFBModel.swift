//
//  UserFBModel.swift
//  Messenger
//
//  Created by Dmitry on 14.09.2021.
//

import Foundation
import FirebaseDatabase

class UserFBModel {
  let firstName: String
  let lastName: String
  let email: String
  var ref: DatabaseReference?
  
  init(firstName: String, lastName: String, email: String) {
    self.firstName = firstName
    self.lastName = lastName
    self.email = email
    ref = nil
  }
  
  init?(snapshot: DataSnapshot) {
    guard
      let value = snapshot.value as? [String: Any],
      let firstName  = value["firstName"] as? String,
      let lastName = value["lastName"] as? String,
      let email = value["email"] as? String
    else {
      return nil
    }
    
    self.ref = snapshot.ref
    self.firstName = firstName
    self.lastName = lastName
    self.email = email
  }
  
  func toAnyObject() -> [AnyHashable: Any] {
    return [ "firstName": firstName, "lastName": lastName, "email": email  ] as [AnyHashable: Any]
  }
  
}
