//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Dmitry on 21.09.2021.
//

import UIKit

class NewConversationViewController: UIViewController {
  
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
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = "test"
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    //present(presenter.viewDidLogout(), animated: true)
  }
}

extension NewConversationViewController: UISearchBarDelegate {
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    
  }
}
//MARK: - PresenterProtocol
extension NewConversationViewController: NewConversationViewProtocol {
  
}
