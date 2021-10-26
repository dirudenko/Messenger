//
//  ChatViewController.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import AVFoundation
import AVKit
import CoreLocation

class ChatViewController: MessagesViewController {
  
  var isNewConversation = false
  private let otherUserEmail: String
  private var messages = [Message]()
  private var conversationID: String?
  
  private let presenter: ChatViewPresenterProtocol
  
  private var sender: Sender? {
    let sender = Sender(senderId: presenter.safeMail(),
                        displayName: "",
                        photoURL: "")
    return sender
  }
  
  init(presenter: ChatViewPresenterProtocol, email: String) {
    self.presenter = presenter
    self.otherUserEmail = email
    super.init(nibName: nil, bundle: nil)
    if let id = presenter.conversationID {
      presenter.listenForMessages(id: id)
      self.conversationID = id
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    messageInputBar.delegate = self
    messagesCollectionView.messageCellDelegate = self
}
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    setupInputButton()
    messagesCollectionView.reloadData()
    messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
    messageInputBar.inputTextView.becomeFirstResponder()
  }
}
//MARK: - Private func
extension ChatViewController {
  private func setupInputButton() {
    let buttonSize: Double = 36
    
    let button = InputBarButtonItem()
    button.setSize(CGSize(width: buttonSize - 1, height: buttonSize - 1), animated: false)
    button.setImage(UIImage(systemName: "plus"), for: .normal)
    button.onTouchUpInside { _ in
      self.presentInputActionSheet()
    }
    messageInputBar.setLeftStackViewWidthConstant(to: buttonSize, animated: false)
    messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
  }
  
  private func presentInputActionSheet() {
    let actionSheet = UIAlertController(title: "Добавьте вложение",
                                        message: "Какие объекты вы хотите добавить?",
                                        preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: "Фото",
                                        style: .default,
                                        handler: { [weak self] _ in
      self?.presentPhotoActionSheet()
    }))
    actionSheet.addAction(UIAlertAction(title: "Видео",
                                        style: .default,
                                        handler: { [weak self] _ in
      self?.presentVideoActionSheet()
    }))
    actionSheet.addAction(UIAlertAction(title: "Аудио",
                                        style: .default,
                                        handler: { [weak self] _ in
      
    }))
    actionSheet.addAction(UIAlertAction(title: "Геопозиция",
                                        style: .default,
                                        handler: { [weak self] _ in
      self?.presentLocationPicker()
    }))
    actionSheet.addAction(UIAlertAction(title: "Отмена",
                                        style: .cancel,
                                        handler: nil))
    present(actionSheet, animated: true)
  }
  
  
  private func presentLocationPicker() {
    let vc = LocationPickerViewController(coordinates: nil)
    vc.title = "Укажите геопозицию"
    vc.navigationItem.largeTitleDisplayMode = .never
    
    vc.complition = { [weak self] coordinates in
      guard let self = self else { return }
      let longitude: Double = coordinates.longitude
      let latitude: Double = coordinates.latitude
      let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: .zero)
      self.presenter.sendLocation(location: location,
                             email: self.otherUserEmail,
                             conversationID: self.conversationID,
                             name: self.title,
                             sender: self.sender)
    }
    navigationController?.pushViewController(vc, animated: true)
    
  }
  
  private func presentPhotoActionSheet() {
    let actionSheet = UIAlertController(title: "Добавление фотографии",
                                        message: "Откуда вы хотите добавить фотографию?",
                                        preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: "Камера",
                                        style: .default,
                                        handler: { [weak self] _ in
      let picker = UIImagePickerController()
      picker.sourceType = .camera
      picker.delegate = self
      picker.allowsEditing = true
      self?.present(picker, animated: true)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Галерея",
                                        style: .default,
                                        handler: { [weak self] _ in
      let picker = UIImagePickerController()
      picker.sourceType = .photoLibrary
      picker.delegate = self
      picker.allowsEditing = true
      self?.present(picker, animated: true)
    }))
    actionSheet.addAction(UIAlertAction(title: "Отмена",
                                        style: .cancel,
                                        handler: nil))
    present(actionSheet, animated: true)
    
  }
  
  private func presentVideoActionSheet() {
    let actionSheet = UIAlertController(title: "Добавление видео",
                                        message: "Откуда вы хотите добавить видео?",
                                        preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: "Камера",
                                        style: .default,
                                        handler: { [weak self] _ in
      let picker = UIImagePickerController()
      picker.sourceType = .camera
      picker.delegate = self
      picker.mediaTypes = ["public.movie"]
      picker.videoQuality = .typeMedium
      picker.allowsEditing = true
      self?.present(picker, animated: true)
    }))
    
    actionSheet.addAction(UIAlertAction(title: "Галерея",
                                        style: .default,
                                        handler: { [weak self] _ in
      let picker = UIImagePickerController()
      picker.sourceType = .photoLibrary
      picker.delegate = self
      picker.mediaTypes = ["public.movie"]
      picker.videoQuality = .typeMedium
      picker.allowsEditing = true
      self?.present(picker, animated: true)
    }))
    actionSheet.addAction(UIAlertAction(title: "Отмена",
                                        style: .cancel,
                                        handler: nil))
    present(actionSheet, animated: true)
    
  }
  
}

//MARK: - DataSource, Delegate
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
  func currentSender() -> SenderType {
    if let sender = sender {
      return sender
    } else {
      fatalError("sender is nil")
    }
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
  
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
  
  func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    guard let message = message as? Message else { return }
    
    switch message.kind {
    case .photo(let media):
      guard let imageUrl = media.url else { return }
      imageView.sd_setImage(with: imageUrl, completed: nil)
    default:
      break
    }
  }
}

extension ChatViewController: MessageCellDelegate {
  func didTapImage(in cell: MessageCollectionViewCell) {
    guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
    let message = messages[indexPath.section]
    switch message.kind {
    case .photo(let media):
      guard let imageUrl = media.url else { return }
      let vc = MessengerBuilder.buildPhotoViewerViewController(with: imageUrl)
      self.navigationController?.pushViewController(vc, animated: true)
    case .video(let media):
      guard let videoUrl = media.url else { return }
      let vc = AVPlayerViewController()
      vc.player = AVPlayer(url: videoUrl)
      present(vc, animated: true)
    default:
      break
    }
  }
  
  
  func didTapMessage(in cell: MessageCollectionViewCell) {
    guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
    let message = messages[indexPath.section]
    switch message.kind {
    case .location(let locationData):
      let coordinates = locationData.location.coordinate
      let vc = LocationPickerViewController(coordinates: coordinates)
      vc.title = "Геопозиция"
      self.navigationController?.pushViewController(vc, animated: true)
    default:
      break
    }
  }
}
//MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
  /// отправка  текстового сообщения
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
          let sender = sender,
          let messageId = presenter.createMessageId(for: otherUserEmail) else { return }
    let message = Message(sender: sender,
                          messageId: messageId,
                          sentDate: Date(),
                          kind: .text(text))
    // send message
    if isNewConversation {
      //create conv
      
      presenter.createNewConversation(message: message,
                                      with: otherUserEmail,
                                      title: self.title ?? "User") { success in
        if success {
          self.isNewConversation = false
        }
      }
      
    } else {
      // append conv
      guard let conversationID = conversationID,
            let name = self.title else { return }
      presenter.appendToConversation(message: message,
                                     with: otherUserEmail,
                                     to: conversationID,
                                     name: name)
    }
    inputBar.inputTextView.text = ""
  }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    
    if let _ = info[.editedImage] as? UIImage {
    
    presenter.sendPhotoMessage(email: otherUserEmail,
                               conversationID: conversationID,
                               info: info,
                               name: self.title,
                               sender: sender)
    } else {
      presenter.sendVideoMessage(email: otherUserEmail,
                                 conversationID: conversationID,
                                 info: info,
                                 name: self.title,
                                 sender: sender)
    }
  }
}

//MARK: - PresenterProtocol
extension ChatViewController: ChatViewProtocol {
  func alertUser(with text: String) {
    let alert = UIAlertController(title: "Ошибка", message: text, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    present(alert, animated: true)
  }
  
  func successGetMessages(messages: [Message]) {
    self.messages = messages
    DispatchQueue.main.async {
      self.messagesCollectionView.reloadData()
    }
  }
}
