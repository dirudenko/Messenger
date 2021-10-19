//
//  ProfileView.swift
//  Messenger
//
//  Created by Dmitry on 18.09.2021.
//

import UIKit

class ProfileView: UIView {
  
  let tableView = UITableView()
  let headerView = UIView()
  
  private let imageSize: CGFloat = 150
  
  private(set) lazy var photoImage: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = imageSize / 2
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(systemName: "person.circle")
    imageView.tintColor = .systemBlue
    imageView.layer.masksToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.configureUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.configureUI()
  }
  
  private func configureUI() {
    self.backgroundColor = .white
    self.addTableView()
    self.setupConstraints()
  }
  
  private func addTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    headerView.translatesAutoresizingMaskIntoConstraints = false
    
    headerView.backgroundColor = .blue
    self.addSubview(tableView)
    self.addSubview(headerView)
    addPhoto()
  }
  
  private func setupConstraints() {
    let safeArea = self.safeAreaLayoutGuide
    
    NSLayoutConstraint.activate([
      
      self.headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
      self.headerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
      self.headerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
      self.headerView.heightAnchor.constraint(equalToConstant: 200),
      
      
      self.tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8.0),
      self.tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
      self.tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
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
