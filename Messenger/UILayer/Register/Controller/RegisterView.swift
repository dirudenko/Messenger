//
//  RegisterView.swift
//  Messenger
//
//  Created by Dmitry on 05.09.2021.
//

import UIKit

class RegisterView: UIView {
  
  
  private let imageSize: CGFloat = 200
  
  private(set) lazy var avatarImage: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = imageSize / 2
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(systemName: "person.circle")
    imageView.tintColor = .systemBlue
    imageView.layer.masksToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private(set) lazy var firstNameField: UITextField = {
    let field = UITextField()
    field.translatesAutoresizingMaskIntoConstraints = false
    field.placeholder = "Введите имя"
    field.borderStyle = .roundedRect
    field.autocorrectionType = .no
    field.autocapitalizationType = .none
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .white
    field.returnKeyType = .continue
    return field
  }()
  
  private(set) lazy var lastNameField: UITextField = {
    let field = UITextField()
    field.translatesAutoresizingMaskIntoConstraints = false
    field.placeholder = "Введите фамилию"
    field.borderStyle = .roundedRect
    field.autocorrectionType = .no
    field.autocapitalizationType = .none
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .white
    field.returnKeyType = .continue
    return field
  }()
  
  private(set) lazy var emailField: UITextField = {
    let field = UITextField()
    field.translatesAutoresizingMaskIntoConstraints = false
    field.placeholder = "Введите email"
    field.borderStyle = .roundedRect
    field.autocorrectionType = .no
    field.autocapitalizationType = .none
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .white
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
    field.backgroundColor = .white
    field.returnKeyType = .done
    return field
  }()
  
  private(set) lazy var createButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Создать", for: .normal)
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 12.0
    button.layer.masksToBounds = true
    button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    
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
    self.addSubview(avatarImage)
    self.addSubview(firstNameField)
    self.addSubview(lastNameField)
    self.addSubview(emailField)
    self.addSubview(passwordField)
    self.addSubview(createButton)
    
    
    NSLayoutConstraint.activate([
      
      avatarImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: imageSize / 2),
      avatarImage.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: -imageSize / 2),
      avatarImage.widthAnchor.constraint(equalToConstant: imageSize),
      avatarImage.heightAnchor.constraint(equalToConstant: imageSize),
      
      firstNameField.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 20),
      firstNameField.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 16),
      firstNameField.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -16),
      firstNameField.heightAnchor.constraint(equalToConstant: 52),
      
      lastNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: 12),
      lastNameField.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 16),
      lastNameField.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -16),
      lastNameField.heightAnchor.constraint(equalToConstant: 52),
      
      emailField.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: 12),
      emailField.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 16),
      emailField.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -16),
      emailField.heightAnchor.constraint(equalToConstant: 52),
      
      passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
      passwordField.leftAnchor.constraint(equalTo: emailField.leftAnchor),
      passwordField.rightAnchor.constraint(equalTo: emailField.rightAnchor),
      passwordField.heightAnchor.constraint(equalToConstant: 52),
      
      createButton.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: -100),
      createButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
      createButton.widthAnchor.constraint(equalToConstant: 200),
      createButton.heightAnchor.constraint(equalToConstant: 32),
    ])
  }
}

