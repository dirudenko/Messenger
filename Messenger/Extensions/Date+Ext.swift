//
//  Date+Ext.swift
//  Messenger
//
//  Created by Dmitry on 23.11.2021.
//

import Foundation

extension Date {
  
  func dateFormatter() -> String {
   let formatter = DateFormatter()
   formatter.dateStyle = .medium
   formatter.timeStyle = .long
   formatter.locale = .current
   let stringDate = formatter.string(from: self)
   return stringDate
 }
  
}
