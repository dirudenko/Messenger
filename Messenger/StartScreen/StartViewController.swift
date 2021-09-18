//
//  StartViewController.swift
//  Messenger
//
//  Created by Dmitry on 13.09.2021.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseAuth


class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

      view.backgroundColor = .systemBlue
    }
    

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
   // if let token = KeychainWrapper.standard.string(forKey: "login") {
      
   // } else {
    authorizate()
   // }
  }

  
  private func authorizate() {
    if FirebaseAuth.Auth.auth().currentUser == nil {
      let vc = MessengerBuilder.buildLoginScreen()
      vc.modalPresentationStyle = .fullScreen
      //present(vc, animated: false)
      navigationController?.pushViewController(vc, animated: false)
    
//    if let token = params["access_token"] {
//         KeychainWrapper.standard.set(token, forKey: "login")
//         Session.shared.token = token
//         showMainTabBar()
//       }
  }
}
}
