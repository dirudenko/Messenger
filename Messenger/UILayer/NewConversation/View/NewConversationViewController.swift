//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit

class NewConversationViewController: UIViewController {
  
  private let newConversation = NewConversationView()
   let presenter: NewConversationViewPresenterProtocol
  
  init(presenter: NewConversationViewPresenterProtocol) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    self.view = newConversation
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.topItem?.titleView = newConversation.searchBar
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отмена",
                                                        style: .done,
                                                        target: self,
                                                        action: #selector(dismissSearch))
    newConversation.searchBar.delegate = self
    newConversation.searchBar.becomeFirstResponder()
    newConversation.tableView.delegate = self
    newConversation.tableView.dataSource = self
  }
  //MARK: - Private func
  @objc private func dismissSearch() {
    dismiss(animated: true, completion: nil)
  }
}

//MARK: - DataSource, Delegate
extension NewConversationViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.results.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = presenter.results[indexPath.row]["name"]
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let targetUser = presenter.results[indexPath.row]
    dismiss(animated: true, completion:  { [weak self] in
      self?.presenter.complition?(targetUser)
    })
      
  //  presenter.complition?(targetUser)
    
  }
}

extension NewConversationViewController: UISearchBarDelegate {
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//    guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
//      return
//    }
//    newConversation.searchBar.resignFirstResponder()
//
//    presenter.results.removeAll()
//    presenter.searchUsers(query: text)
    presenter.results.removeAll()
    
  }
  
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
        return
      }
      newConversation.searchBar.resignFirstResponder()
      
      presenter.results.removeAll()
      presenter.searchUsers(query: text)
  }
  
}
//MARK: - PresenterProtocol
extension NewConversationViewController: NewConversationViewProtocol {
  func updateUI() {
    if presenter.results.isEmpty {
      newConversation.noResultLabel.isHidden = false
      newConversation.tableView.isHidden = true
      newConversation.tableView.reloadData()
    } else {
      newConversation.noResultLabel.isHidden = true
      newConversation.tableView.isHidden = false
      newConversation.tableView.reloadData()
    }
  }
}
