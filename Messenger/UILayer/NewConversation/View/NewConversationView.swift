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
   tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    return tableView
  }()
  
  private let noResultLabel: UILabel = {
    let label = UILabel()
    label.isHidden = true
    label.text = "Нет результата"
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
    self.backgroundColor = .white
    self.addTableView()
    self.setupConstraints()
  }

  private func addTableView() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(tableView)
  }
  
  private func setupConstraints() {
    let safeArea = self.safeAreaLayoutGuide
    
    NSLayoutConstraint.activate([
      
      self.tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
      self.tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
      self.tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
    ])
}
  
}

