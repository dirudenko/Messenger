//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Dmitry on 05.09.2021.
//

import UIKit

class RegisterViewController: UIViewController {
  
  private let registerView = RegisterView()
  private let presenter: RegisterViewPresenterProtocol
  
  init(presenter: RegisterViewPresenterProtocol) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
      super.loadView()
      self.view = registerView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeAvatar))
    registerView.createButton.addTarget(self, action: #selector(didTapRegister), for: .touchDown)
    registerView.avatarImage.isUserInteractionEnabled = true
    registerView.avatarImage.addGestureRecognizer(gesture)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.isHidden = true
  }
  
  
  @objc private func didTapRegister() {
    
    registerView.firstNameField.resignFirstResponder()
    registerView.lastNameField.resignFirstResponder()
    registerView.emailField.resignFirstResponder()
    registerView.passwordField.resignFirstResponder()
    
    guard let email = registerView.emailField.text,
          let firstName = registerView.firstNameField.text,
          let lastName = registerView.lastNameField.text,
          let password = registerView.passwordField.text,
          !lastName.isEmpty,
          !password.isEmpty,
          !email.isEmpty,
          !firstName.isEmpty else {
      alertUser("Введите корректную информацию о пользователе")
      return
    }
    
    presenter.viewDidRegister(firstName: firstName, lastName: lastName, email: email, password: password)
  }
  
  @objc private func didTapChangeAvatar() {
    presentPhoto()
  }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  private func presentPhoto() {
    let action = UIAlertController(title: "Фотография профиля",
                                   message: "Как вы хотите выбрать фотграфию профиля",
                                   preferredStyle: .actionSheet)
    action.addAction(UIAlertAction(title: "Отменить",
                                   style: .cancel,
                                   handler: nil))
    action.addAction(UIAlertAction(title: "Сделать фотографию",
                                   style: .default,
                                   handler: { [weak self] _ in
                                    self?.presentFromPhotoLibrary()
                                   }))
    action.addAction(UIAlertAction(title: "Выбрать фотографию",
                                   style: .default,
                                   handler: { [weak self]_ in
                                    self?.presentFromPhotoLibrary()
                                   }))
    
    present(action, animated: true)
  }
  
  
  private func presentFromCamera() {
    let vc = UIImagePickerController()
    vc.sourceType = .camera
    vc.delegate = self
    vc.allowsEditing = true
    present(vc, animated: true)
  }
  
  private func presentFromPhotoLibrary() {
    let vc = UIImagePickerController()
    vc.sourceType = .photoLibrary
    vc.delegate = self
    vc.allowsEditing = true
    present(vc, animated: true)
  }
  
  internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
    registerView.avatarImage.image = selectedImage
  }
  
  internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
}

extension RegisterViewController: RegisterViewProtocol {
  func success() {
    let alert = UIAlertController(title: "Ура", message: "Пользователь успешно создан", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:
                                    { _ in
                                      self.navigationController?.popViewController(animated: true)
                                    }))
    present(alert, animated: true)
    
   // navigationController?.dismiss(animated: true, completion: nil)

    
  }
  func alertUser(_ alert: String) {
    let alert = UIAlertController(title: "Ошибка", message: alert, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    present(alert, animated: true)
  }
}
