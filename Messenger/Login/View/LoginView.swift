//
//  LoginView.swift
//  Messenger
//
//  Created by Dmitry on 04.09.2021.
//

import UIKit

class LoginView: UIView {
  
  private(set) lazy var loginLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 20)
    label.text = "Введите логин"
    return label
  }()
  
  private(set) lazy var loginField: UITextField = {
    let view = UITextField()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.placeholder = "Введите логин"
    view.borderStyle = .roundedRect
    return view
  }()
  
  
  private(set) lazy var passwordLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 20)
    label.text = "Введите пароль"
    return label
  }()
  
  private(set) lazy var passwordField: UITextField = {
    let view = UITextField()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.placeholder = "Введите пароль"
    view.borderStyle = .roundedRect
    view.isSecureTextEntry = true
    return view
  }()
  
  private(set) lazy var loginButton: UIButton = {
      let button = UIButton()
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setTitle("Войти", for: .normal)
      button.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
      button.layer.cornerRadius = 16.0
      
      return button
  }()
  
  private(set) lazy var createButton: UIButton = {
      let button = UIButton()
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setTitle("Создать аккаунт", for: .normal)
    button.backgroundColor = .clear
      button.setTitleColor(.systemBlue, for: .normal)
      button.layer.cornerRadius = 16
      
      return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureUI()
  }
  
  private func configureUI() {
    self.backgroundColor = .white
    
    self.addSubview(loginLabel)
    self.addSubview(loginField)
    self.addSubview(passwordLabel)
    self.addSubview(loginButton)
    self.addSubview(createButton)
    self.addSubview(passwordField)
    
    
    NSLayoutConstraint.activate([
      loginLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: -150),
      loginLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 16),
      loginLabel.widthAnchor.constraint(equalToConstant: 200),
      
      loginField.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 12),
      loginField.leftAnchor.constraint(equalTo: loginLabel.leftAnchor, constant: 5),
      loginField.widthAnchor.constraint(equalToConstant: 200),

      passwordLabel.topAnchor.constraint(equalTo: loginField.bottomAnchor, constant: 12),
      passwordLabel.leftAnchor.constraint(equalTo: loginLabel.leftAnchor),
      passwordLabel.rightAnchor.constraint(equalTo: loginLabel.rightAnchor),
      
      passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 12),
      passwordField.leftAnchor.constraint(equalTo: passwordLabel.leftAnchor, constant: 5),
      passwordField.widthAnchor.constraint(equalToConstant: 200),

      loginButton.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: -40),
      loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
      loginButton.widthAnchor.constraint(equalToConstant: 80),
      loginButton.heightAnchor.constraint(equalToConstant: 32),

      createButton.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: -100),
      createButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
      createButton.widthAnchor.constraint(equalToConstant: 200),
      createButton.heightAnchor.constraint(equalToConstant: 32),
    ])
  }
}
