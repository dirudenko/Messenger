//
//  ProfileTableViewCell.swift
//  Messenger
//
//  Created by Dmitry on 28.10.2021.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

  let imageSize: CGFloat = 150
  private let storageService = StorageService()
  
  private(set) lazy var userImage: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = imageSize / 2
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(systemName: "person.circle")
    imageView.tintColor = .secondarySystemBackground
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
  
  private(set) lazy var userEmailLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 19, weight: .regular)
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(userNameLabel)
    contentView.addSubview(userEmailLabel)
    backgroundColor = .systemBackground
    addConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func addConstraints() {
    NSLayoutConstraint.activate([
      userNameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      userNameLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: 10),
      userNameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
      userNameLabel.heightAnchor.constraint(equalToConstant: 52),
      
      userEmailLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10),
      userEmailLabel.leftAnchor.constraint(equalTo: userNameLabel.rightAnchor, constant: 10),
      userEmailLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
      userEmailLabel.heightAnchor.constraint(equalToConstant: 52)
    ])
  }
  
  func configure(with model: ProfileModel) {
    textLabel?.text = model.title
    switch model.viewProfileType {
    case .logout:
      textLabel?.text = "Выйти"
      textLabel?.textColor = .red
      textLabel?.textAlignment = .center
    case.info:
      textLabel?.textAlignment = .left
      selectionStyle = .none
    }
  }
}
