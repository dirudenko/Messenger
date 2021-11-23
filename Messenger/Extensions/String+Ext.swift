//
//  String+Ext.swift
//  Messenger
//
//  Created by Dmitry on 23.11.2021.
//

import Foundation

extension String {
    
  var safeEmail: String {
    var safeEmail = self.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    return safeEmail
  }
}
