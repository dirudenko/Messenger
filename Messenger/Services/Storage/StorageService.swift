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
  func uploadMessagePhoto(with data: Data,
                          fileName: String,
                          complition: @escaping (Result<String, Error>) -> Void)
  func safeEmail(email: String) -> String
  func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void)
  func uploadMessageVideo(with fileUrl: URL, fileName: String, complition: @escaping (Result<String, Error>) -> Void)
}

final class StorageService: StorageServiceProtocol {
  
  private let storage = Storage.storage().reference()
  
  func uploadProfilePhoto(with data: Data,
                          fileName: String,
                          complition: @escaping (Result<String, Error>) -> Void) {
    storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
      guard let self = self,
            error == nil else {
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
  
  
  func uploadMessagePhoto(with data: Data,
                          fileName: String,
                          complition: @escaping (Result<String, Error>) -> Void) {
    storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
      guard let self = self,
            error == nil else {
        complition(.failure(StorageErrors.failedToUpload))
        return
      }
      
      self.storage.child("message_images/\(fileName)").downloadURL { url, error in
        guard let url = url else {
          complition(.failure(StorageErrors.failedToGetUploadedURL))
          return
        }
        let urlString = url.absoluteString
        complition(.success(urlString))
      }
    })
  }
  
  func uploadMessageVideo(with fileUrl: URL,
                          fileName: String,
                          complition: @escaping (Result<String, Error>) -> Void) {
    storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self] metadata, error in
      guard let self = self,
            error == nil else {
              complition(.failure(StorageErrors.failedToUpload))
              return
            }
      
      self.storage.child("message_videos/\(fileName)").downloadURL { url, error in
        guard let url = url else {
          complition(.failure(StorageErrors.failedToGetUploadedURL))
          return
        }
        let urlString = url.absoluteString
        complition(.success(urlString))
      }
    })
  }
  
  func safeEmail(email: String) -> String {
    var safeEmail = email.replacingOccurrences(of: ".", with: "-")
    safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
    return safeEmail
  }
  
  func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
    let reference = storage.child(path)
    reference.downloadURL { url, error in
      guard let url = url, error == nil else {
        completion(.failure(StorageErrors.failedToGetUploadedURL))
        return
      }
      completion(.success(url))
    }
  }
}
