//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit

class NewConversationViewController: UIViewController {
  
  var complition: ((SearchResult) ->(Void))?
  var results = [SearchResult]()
  private let newConversation = NewConversationView()
  private let presenter: NewConversationViewPresenterProtocol
  
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
    return results.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewConversationTableViewCell", for: indexPath) as? NewConversationTableViewCell else { return UITableViewCell() }
    cell.configure(with: results[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let targetUser = results[indexPath.row]
    dismiss(animated: true, completion:  { [weak self] in
      self?.complition?(targetUser)
    })
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return NewConversationTableViewCell().imageSize + 20
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
    results.removeAll()
    
  }
  
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
        return
      }
      newConversation.searchBar.resignFirstResponder()
      
      results.removeAll()
      presenter.searchUsers(query: text)
  }
  
}
//MARK: - PresenterProtocol
extension NewConversationViewController: NewConversationViewProtocol {
  func updateUI(with results: [SearchResult]) {
    if results.isEmpty {
      newConversation.noResultLabel.isHidden = false
      newConversation.tableView.isHidden = true
      newConversation.tableView.reloadData()
    } else {
      newConversation.noResultLabel.isHidden = true
      newConversation.tableView.isHidden = false
      self.results = results
      newConversation.tableView.reloadData()
    }
  }
}
