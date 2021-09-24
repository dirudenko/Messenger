//
//  StorageService.swift
//  Messenger
//
//  Created by Dmitry on 24.09.2021.
//

import Foundation
import FirebaseStorage

protocol StorageServiceProtocol: AnyObject {
  func uploadProfilePhoto(with data: Data,
                          fileName: String,
                          complition: @escaping (Result<String, Error>) -> Void)
}

final class StorageService: StorageServiceProtocol {
  
  private let storage = Storage.storage().reference()
  
  func uploadProfilePhoto(with data: Data,
                          fileName: String,
                          complition: @escaping (Result<String, Error>) -> Void) {
    storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
      guard error == nil else {
        complition(.failure(StorageErrors.failedToUpload))
        return
      }
      
      self.storage.child("images/\(fileName)").downloadURL { url, error in
        guard let url = url else {
          complition(.failure(StorageErrors.failedToGetUploadedURL))
          return
        }
        let urlString = url.absoluteString
        complition(.success(urlString))
      }
      
    })
  }
  
}
