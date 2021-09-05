//
//  LoginViewController.swift
//  Messenger
//
//  Created by Dmitry on 04.09.2021.
//

import UIKit

class LoginViewController: UIViewController {

  private let loginView = LoginView()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      navigationController?.navigationBar.isHidden = true

      loginView.createButton.addTarget(self, action: #selector(didTapRegister), for: .touchDown)
      loginView.loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchDown)
      self.view = loginView
    }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.isHidden = false
  }
  
  @objc private func didTapRegister() {
    let vc = MessengerBuilder.buildRegisterViewController()
    navigationController?.pushViewController(vc, animated: true)
  }
  
  @objc private func didTapLogin() {
    
    loginView.loginField.resignFirstResponder()
    loginView.passwordField.resignFirstResponder()
    
    guard let login = loginView.loginField.text,
          let password = loginView.passwordField.text,
          !login.isEmpty,
          !password.isEmpty else {
      alertUser()
      return
    }
    print("LOGIN")
  }
  
  private func alertUser() {
    let alert = UIAlertController(title: "Ошибка", message:"Введите корректный логин и пароль", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
      self.loginView.loginField.text = ""
      self.loginView.passwordField.text = ""
    }))
    present(alert, animated: true)
  }
}
