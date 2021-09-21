//
//  ConversationsViewController.swift
//  Messenger
//
//  Created by Dmitry on 13.09.2021.
//

import UIKit

class ConversationsViewController: UIViewController {
  
  private let presenter: ConversationsViewPresenterProtocol
  private let chatsView = ConversationsView()
  
  init(presenter: ConversationsViewPresenterProtocol) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    self.view = chatsView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                        target: self,
                                                        action: #selector(didTabComposeButton))
    chatsView.tableView.delegate = self
    chatsView.tableView.dataSource = self
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presenter.viewDidAuthorizate()
  }
  //MARK: - Private func
  @objc private func didTabComposeButton() {
    let vc = MessengerBuilder.buildNewConversationViewController()
    let navVC = UINavigationController(rootViewController: vc)
    present(navVC, animated: true)
  }
  
}
//MARK: - DataSource, Delegate
extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = "test"
    cell.accessoryType = .disclosureIndicator
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    presenter.viewDidSelectChat()
  }
}
//MARK: - Protocol
extension ConversationsViewController: ConversationsViewProtocol {
  func openChat() {
    let vc = MessengerBuilder.buildChatViewController()
    // имя пользователя
    vc.title = "TEST"
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
    //present(vc, animated: true)
    
  }
  
  func sucessAuthorizate() {
    let vc = MessengerBuilder.buildLoginScreenViewController()
    vc.modalPresentationStyle = .fullScreen
    navigationController?.pushViewController(vc, animated: false)
  }
  
  
  
}
