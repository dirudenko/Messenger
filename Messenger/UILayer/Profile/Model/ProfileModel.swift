//
//  ProfileModel.swift
//  Messenger
//
//  Created by Dmitry on 28.10.2021.
//

import Foundation

enum ProfileModelType {
  case info, logout
}

struct ProfileModel {
  let viewProfileType: ProfileModelType
  let title: String
  let handler: (() -> Void)?
}
