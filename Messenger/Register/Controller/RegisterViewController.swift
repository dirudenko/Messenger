//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Dmitry on 05.09.2021.
//

import UIKit

class RegisterViewController: UIViewController {
    
  private let registerView = RegisterView()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      //navigationController?.navigationBar.isHidden = false

      let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeAvatar))
      registerView.createButton.addTarget(self, action: #selector(didTapRegister), for: .touchDown)
      registerView.avatarImage.isUserInteractionEnabled = true
      registerView.avatarImage.addGestureRecognizer(gesture)
      
      self.view = registerView
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
      alertUser()
      return
    }
  }
  
  @objc private func didTapChangeAvatar() {
    presentPhoto()
  }
  
  private func alertUser() {
    let alert = UIAlertController(title: "Ошибка", message:"Введите корректную информацию о пользователе", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    present(alert, animated: true)
  }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func presentPhoto() {
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
  
  
  func presentFromCamera() {
    let vc = UIImagePickerController()
    vc.sourceType = .camera
    vc.delegate = self
    vc.allowsEditing = true
    present(vc, animated: true)
  }
  
  func presentFromPhotoLibrary() {
    let vc = UIImagePickerController()
    vc.sourceType = .photoLibrary
    vc.delegate = self
    vc.allowsEditing = true
    present(vc, animated: true)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
    registerView.avatarImage.image = selectedImage
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
}
