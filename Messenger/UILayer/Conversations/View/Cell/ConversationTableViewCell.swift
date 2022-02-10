//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by Dmitry on 04.10.2021.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
  
  let imageSize: CGFloat = 100
  private let storageService = StorageService()
  
  private(set) lazy var userImage: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = imageSize / 2
    imageView.layer.masksToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private(set) lazy var userNameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 21, weight: .semibold)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private(set) lazy var userMessageLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 19, weight: .regular)
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(userImage)
    contentView.addSubview(userNameLabel)
    contentView.addSubview(userMessageLabel)
    backgroundColor = .systemBackground
    addConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func addConstraints() {
    NSLayoutConstraint.activate([
      userImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
      userImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
      userImage.widthAnchor.constraint(equalToConstant: imageSize),
      userImage.heightAnchor.constraint(equalToConstant: imageSize),
      
      userNameLabel.topAnchor.constraint(equalTo: userImage.topAnchor),
      userNameLabel.leftAnchor.constraint(equalTo: userImage.rightAnchor, constant: 10),
      userNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
      userNameLabel.heightAnchor.constraint(equalToConstant: 52),
      
      userMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10),
      userMessageLabel.leftAnchor.constraint(equalTo: userImage.rightAnchor, constant: 10),
      userMessageLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
      userMessageLabel.heightAnchor.constraint(equalToConstant: 52)
    ])
  }
  
  func configure(with model: Conversation) {
    userMessageLabel.text = model.latestMessage.text
    userNameLabel.text = model.name
    let path = "images/\(model.otherUserEmail)_profile_picture.png"
    storageService.downloadURL(for: path) { [weak self] result in
      switch result {
      case .success(let url):
        DispatchQueue.main.async {
          self?.userImage.sd_setImage(with: url, completed: nil)
        }
      case .failure(let error):
        print("Error to get image \(error)")
      }
    }
  }
}
