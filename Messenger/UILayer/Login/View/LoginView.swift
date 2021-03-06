//
//  LoginView.swift
//  Messenger
//
//  Created by Dmitry on 04.09.2021.
//

import UIKit
import GoogleSignIn

class LoginView: UIView {
  
  private(set) lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    return scrollView
  }()
  
  private(set) lazy var logoImage: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 30.0
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(named: "logo")
    imageView.tintColor = .systemBlue
    imageView.layer.masksToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private(set) lazy var loginField: UITextField = {
    let field = UITextField()
    field.translatesAutoresizingMaskIntoConstraints = false
    field.placeholder = "Введите логин"
    field.borderStyle = .roundedRect
    field.autocorrectionType = .no
    field.autocapitalizationType = .none
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .secondarySystemBackground
    field.returnKeyType = .continue
    return field
  }()
  
  private(set) lazy var passwordField: UITextField = {
    let field = UITextField()
    field.translatesAutoresizingMaskIntoConstraints = false
    field.placeholder = "Введите пароль"
    field.borderStyle = .roundedRect
    field.isSecureTextEntry = true
    field.borderStyle = .roundedRect
    field.autocorrectionType = .no
    field.autocapitalizationType = .none
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .secondarySystemBackground
    field.returnKeyType = .done
    return field
  }()
  
  private(set) lazy var loginButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Войти", for: .normal)
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 12.0
    button.layer.masksToBounds = true
    button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
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
  
  private(set) lazy var googleButton: GIDSignInButton = {
    let button = GIDSignInButton()
    button.translatesAutoresizingMaskIntoConstraints = false
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
    backgroundColor = .systemBackground
    addLogo()
    addSubview(loginField)
    addSubview(loginButton)
    addSubview(createButton)
    addSubview(passwordField)
    addSubview(googleButton)
    passwordField.delegate = self
    loginField.delegate = self
    
    NSLayoutConstraint.activate([
      
      loginField.topAnchor.constraint(equalTo: self.centerYAnchor, constant: -10),
      loginField.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 16),
      loginField.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -16),
      loginField.heightAnchor.constraint(equalToConstant: 52),
      
      passwordField.topAnchor.constraint(equalTo: loginField.bottomAnchor, constant: 12),
      passwordField.leftAnchor.constraint(equalTo: loginField.leftAnchor),
      passwordField.rightAnchor.constraint(equalTo: loginField.rightAnchor),
      passwordField.heightAnchor.constraint(equalToConstant: 52),
      
      loginButton.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: -40),
      loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
      loginButton.widthAnchor.constraint(equalToConstant: 80),
      loginButton.heightAnchor.constraint(equalToConstant: 32),
      
      createButton.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: -100),
      createButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
      createButton.widthAnchor.constraint(equalToConstant: 200),
      createButton.heightAnchor.constraint(equalToConstant: 32),
      
      googleButton.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: -100),
      googleButton.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 16),
      googleButton.heightAnchor.constraint(equalToConstant: 32)
    ])
  }
  
  private func addLogo() {
    addSubview(logoImage)
    let size: CGFloat = 200
    NSLayoutConstraint.activate([
      
      logoImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: size/2),
      logoImage.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: -size/2),
      logoImage.widthAnchor.constraint(equalToConstant: size),
      logoImage.heightAnchor.constraint(equalToConstant: size)
    ])
  }
}

extension LoginView: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    passwordField.resignFirstResponder() // dismiss keyboard
    loginField.resignFirstResponder()
    return true
  }
}
