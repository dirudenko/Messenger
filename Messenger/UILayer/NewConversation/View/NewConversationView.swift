//
//  NewConversationView.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit

class NewConversationView: UIView {
  
  let searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.placeholder = "Найти пользователя..."
    return searchBar
  }()
  
  let tableView: UITableView = {
    let tableView = UITableView()
    tableView.isHidden = true
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(NewConversationTableViewCell.self, forCellReuseIdentifier: "NewConversationTableViewCell")
    return tableView
  }()
  
  let noResultLabel: UILabel = {
    let label = UILabel()
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Нет результата"
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 22, weight: .semibold)
    return label
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
    addSubview(tableView)
    addSubview(noResultLabel)
    setupConstraints()
  }
  
  private func setupConstraints() {
    let safeArea = self.safeAreaLayoutGuide
    
    NSLayoutConstraint.activate([
      
      tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
      
      noResultLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: -10),
      noResultLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 16),
      noResultLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -16),
      noResultLabel.heightAnchor.constraint(equalToConstant: 52)
      
    ])
  }
}

