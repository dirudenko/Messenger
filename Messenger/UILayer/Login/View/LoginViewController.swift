//
//  LoginViewController.swift
//  Messenger
//
//  Created by Dmitry on 04.09.2021.
//

import UIKit

class LoginViewController: UIViewController {
  
  private let loginView = LoginView()
  private let presenter: LoginViewPresenterProtocol
  
  init(presenter: LoginViewPresenterProtocol) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
      super.loadView()
      self.view = loginView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.isHidden = true
    loginView.createButton.addTarget(self, action: #selector(didTapRegister), for: .touchDown)
    loginView.loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchDown)
    loginView.googleButton.addTarget(self, action: #selector(didTapGoogle), for: .touchDown)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationController?.navigationBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.isHidden = false
  }
  //MARK: - Private func
  @objc private func didTapRegister() {
    presenter.viewDidRegister()
  }
  
  @objc private func didTapLogin() {
    
    loginView.loginField.resignFirstResponder()
    loginView.passwordField.resignFirstResponder()
    
    guard let login = loginView.loginField.text,
          let password = loginView.passwordField.text,
          !login.isEmpty,
          !password.isEmpty else {
      alertUser("Введите корректный логин и пароль")
      return
    }
    presenter.viewDidLogin(email: login, password: password)
  }
  
  @objc private func didTapGoogle() {
    presenter.viewDidGoogleRegister()
  }
  
}
//MARK: - PresenterProtocol
extension LoginViewController: LoginViewProtocol {
  func sucessToLogin() {
    
    navigationController?.dismiss(animated: false, completion: nil)
    let vc = MessengerBuilder.buildTabBar()
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: false)
  }
  
  func alertUser(_ alert: String) {
    let alert = UIAlertController(title: "Ошибка", message: alert, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
      self.loginView.loginField.text = ""
      self.loginView.passwordField.text = ""
    }))
    present(alert, animated: true)
  }
}
