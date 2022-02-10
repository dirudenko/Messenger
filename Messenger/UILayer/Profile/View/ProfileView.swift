//
//  ProfileView.swift
//  Messenger
//
//  Created by Dmitry on 18.09.2021.
//

import UIKit

class ProfileView: UIView {
  
  let tableView: UITableView = {
    let tableView = UITableView()
    // tableView.isHidden = true
    tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: "ProfileTableViewCell")
    return tableView
  }()
  
  let headerView = UIView()
  
  private let imageSize: CGFloat = 150
  
  private(set) lazy var photoImage: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = imageSize / 2
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(systemName: "person.circle")
    imageView.tintColor = .secondarySystemBackground
    imageView.layer.masksToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureUI()
  }
  
  private func configureUI() {
    backgroundColor = .systemBackground
    addTableView()
    setupConstraints()
  }
  
  private func addTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    headerView.translatesAutoresizingMaskIntoConstraints = false
    
    headerView.backgroundColor = .systemBackground
    addSubview(tableView)
    addSubview(headerView)
    addPhoto()
  }
  
  private func setupConstraints() {
    let safeArea = self.safeAreaLayoutGuide
    
    NSLayoutConstraint.activate([
      
      headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
      headerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
      headerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
      headerView.heightAnchor.constraint(equalToConstant: 200),
      
      tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8.0),
      tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
    ])
  }
  
  private func addPhoto() {
    headerView.addSubview(photoImage)
    NSLayoutConstraint.activate([
      
      photoImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: imageSize/4 ),
      photoImage.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: -imageSize/2),
      photoImage.widthAnchor.constraint(equalToConstant: imageSize),
      photoImage.heightAnchor.constraint(equalToConstant: imageSize)
    ])
  }
}
