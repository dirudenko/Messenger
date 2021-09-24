//
//  StorageErrors.swift
//  Messenger
//
//  Created by Dmitry on 24.09.2021.
//

import Foundation

enum StorageErrors: Error {
  case failedToUpload
  case failedToGetUploadedURL
}
