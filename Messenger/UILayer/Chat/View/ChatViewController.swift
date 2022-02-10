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
  private var senderImageUrl: URL?
  private var otherUserImageUrl: URL?
  private var email: String {
    let userEmail = UserDefaults.standard.value(forKey: "email") as? String ?? ""
    return userEmail
  }
  
  private let presenter: ChatViewPresenterProtocol
  
  private var sender: Sender? {
    let sender = Sender(senderId: email.safeEmail,
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
      conversationID = id
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
    
   // self.showLoadingView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    setupInputButton()
    messagesCollectionView.reloadData()
    messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
    messageInputBar.inputTextView.becomeFirstResponder()
  }
}
// MARK: - Private func
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
    let viewController = LocationPickerViewController(coordinates: nil)
    viewController.title = "Укажите геопозицию"
    viewController.navigationItem.largeTitleDisplayMode = .never
    
    viewController.complition = { [weak self] coordinates in
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
    navigationController?.pushViewController(viewController, animated: true)
    
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

// MARK: - DataSource, Delegate
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
  func currentSender() -> SenderType {
      return sender!
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
  
  func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    let sender = message.sender
    if sender.senderId == self.sender?.senderId {
      return .link
    }
    return .secondarySystemBackground
  }
  
  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    let sender = message.sender
    if sender.senderId == self.sender?.senderId {
      // show sender image
      if let currentUserUrl = senderImageUrl {
        avatarView.sd_setImage(with: currentUserUrl, completed: nil)
      } else {
        
        let safeMail = email.safeEmail
        let fileName = safeMail + "_profile_picture.png"
        let path = "images/" + fileName
        presenter.downloadURL(for: path, image: avatarView)
        
      }
    } else {
      if let otherUserUrl = otherUserImageUrl {
        avatarView.sd_setImage(with: otherUserUrl, completed: nil)
      } else {
        let otherUserEmail = otherUserEmail
        let safeMail = otherUserEmail.safeEmail
        let fileName = safeMail + "_profile_picture.png"
        let path = "images/" + fileName
        presenter.downloadURL(for: path, image: avatarView)
      }
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
      let viewController = MessengerBuilder.buildPhotoViewerViewController(with: imageUrl)
      navigationController?.pushViewController(viewController, animated: true)
      
    case .video(let media):
      guard let videoUrl = media.url else { return }
      let viewController = AVPlayerViewController()
      viewController.player = AVPlayer(url: videoUrl)
      present(viewController, animated: true)
      
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
      let viewController = LocationPickerViewController(coordinates: coordinates)
      viewController.title = "Геопозиция"
      navigationController?.pushViewController(viewController, animated: true)
    default:
      break
    }
  }
}
// MARK: - InputBarAccessoryViewDelegate
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
      // create conv
      
      presenter.createNewConversation(message: message,
                                      with: otherUserEmail,
                                      title: self.title ?? "User") { [weak self] success in
        if success {
          self?.isNewConversation = false
          let newConversationID = "conversation_\(message.messageId)"
          self?.conversationID = newConversationID
          self?.presenter.listenForMessages(id: newConversationID)
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
    inputBar.inputTextView.text = nil
    messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
  }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    picker.dismiss(animated: true, completion: nil)
    
    if info[.editedImage] as? UIImage != nil {
      
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

// MARK: - PresenterProtocol
extension ChatViewController: ChatViewProtocol {
  func alertUser(with text: String) {
    self.presentAlert(title: "Ошибка", message: text)
  }
  
  func successGetMessages(messages: [Message]) {
    self.messages = messages
    DispatchQueue.main.async {
      self.messagesCollectionView.reloadData()
    }
  }
}
