//
//  ConversationsView.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit

class ConversationsView: UIView {
  
  let tableView: UITableView = {
    let tableView = UITableView()
    tableView.isHidden = true
    tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: "ConversationTableViewCell")
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
  
   let noChatsLabel: UILabel = {
    let label = UILabel()
    label.isHidden = false
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Нет чатов"
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 22, weight: .semibold)
    return label
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
    self.backgroundColor = .systemBackground
    self.addSubview(tableView)
    self.addSubview(noChatsLabel)
    self.setupConstraints()
  }
  
  
  
  private func setupConstraints() {
    let safeArea = self.safeAreaLayoutGuide
    
    NSLayoutConstraint.activate([
      self.tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
      self.tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
      self.tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
      
      noChatsLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: -10),
      noChatsLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 16),
      noChatsLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -16),
      noChatsLabel.heightAnchor.constraint(equalToConstant: 52)
    ])
  }
  
}
