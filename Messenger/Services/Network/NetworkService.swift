//
//  NetworkService.swift
//  Messenger
//
//  Created by Dmitry on 17.02.2022.
//

import Foundation

class NetworkService {
  
  func request(token: String, name: String, content: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
    let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
    var request = URLRequest(url: url)
    request.setValue(Constants.Network.authorizationKey,
                     forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let notify = [ "body": content,
                   "title": name ]
    let json: [String: Any] = ["to": token,
                          "notification": notify
    ]
    let body = try? JSONSerialization.data(withJSONObject: json)
    request.httpMethod = "POST"
    request.httpBody = body
    let task = URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        if let responseJSON = responseJSON as? [String: Any] {
            print(responseJSON)
        }
    }

    task.resume()
    completion(json, nil)
  }
  
}
