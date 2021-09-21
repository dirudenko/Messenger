//
//  ProfileView.swift
//  Messenger
//
//  Created by Dmitry on 18.09.2021.
//

import UIKit

class ProfileView: UIView {

  let tableView = UITableView()

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
    self.tableView.rowHeight = 72.0
    self.tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 12.0, bottom: 0.0, right: 0.0)
    self.tableView.translatesAutoresizingMaskIntoConstraints = false
    self.tableView.isHidden = true
    self.tableView.tableFooterView = UIView()
    self.addSubview(self.tableView)
  }
  
  private func setupConstraints() {
    let safeArea = self.safeAreaLayoutGuide
    
    NSLayoutConstraint.activate([
      
      self.tableView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8.0),
      self.tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
      self.tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
    ])
}
}
