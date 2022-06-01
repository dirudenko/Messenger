//
//  ConversationsViewController.swift
//  Messenger
//
//  Created by Dmitry on 13.09.2021.
//

import UIKit
import SDWebImage

class ConversationsViewController: UIViewController {
  
  private let presenter: ConversationsViewPresenterProtocol
  private let chatsView = ConversationsView()
  private var conversations = [Conversation]()
  
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
    if presenter.viewDidAuthorizate() {
      presenter.startListeningConversation()
    }
  }
  
  // MARK: - Private func
  /// Создание нового окна диалога с пользователем
  @objc private func didTabComposeButton() {
    guard let viewController = MessengerBuilder.buildNewConversationViewController() as? NewConversationViewController else { return }
    viewController.complition = { [weak self] result in
      guard let self = self else { return }
      let currentConversations = self.conversations
      if let targetConversation = currentConversations.first(where: {
        $0.otherUserEmail == result.email.safeEmail
      }) {
        self.createChat(model: targetConversation)
      } else {
        self.startNewConversation(with: result)
      }
    }
    let navigationviewController = UINavigationController(rootViewController: viewController)
    present(navigationviewController, animated: true)
  }
  
  private func startNewConversation(with user: SearchResult) {
    let name = user.name
    let email = user.email
    
    presenter.converstionExists(email: email) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let conversationID):
        guard let viewController = MessengerBuilder.buildChatViewController(with: email, conversationID: conversationID) as? ChatViewController else {
          return
        }
        viewController.title = name
        viewController.isNewConversation = false
        viewController.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(viewController, animated: true)
      case .failure:
        guard let viewController = MessengerBuilder.buildChatViewController(with: email, conversationID: nil) as? ChatViewController else {
          return
        }
        viewController.title = name
        viewController.isNewConversation = true
        viewController.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(viewController, animated: true)
      }
    }
  }
  
  private func createChat(model: Conversation) {
    let viewController = MessengerBuilder.buildChatViewController(with: model.otherUserEmail, conversationID: model.id)
    viewController.title = model.name
    viewController.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(viewController, animated: true)
  }
}
// MARK: - DataSource, Delegate
extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return conversations.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationTableViewCell", for: indexPath)
            as? ConversationTableViewCell else { return UITableViewCell() }
    let model = conversations[indexPath.row]
    cell.configure(with: model)
    cell.accessoryType = .disclosureIndicator
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let model = conversations[indexPath.row]
    createChat(model: model)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return ConversationTableViewCell().imageSize + 20
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let conversationID = conversations[indexPath.row].id
      tableView.beginUpdates()
      presenter.deleteConversation(conversationID: conversationID) { [weak self] success in
        guard let self = self else { return }
        if success {
          self.conversations.remove(at: indexPath.row)
          tableView.deleteRows(at: [indexPath], with: .automatic)
          if self.conversations.isEmpty {
            self.chatsView.tableView.isHidden = true
            self.chatsView.noChatsLabel.isHidden = false
          }
          tableView.reloadData()
        }
      }
      
      tableView.endUpdates()
    }
  }
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .delete
  }
}
// MARK: - PresenterProtocol
extension ConversationsViewController: ConversationsViewProtocol {

  func successGetConversations(conversations: [Conversation]) {
    self.conversations = conversations
    chatsView.tableView.isHidden = false
    chatsView.noChatsLabel.isHidden = true
    DispatchQueue.main.async {
      self.chatsView.tableView.reloadData()
    }
  }
  
  func unableToAuthorizate() {
    let viewController = MessengerBuilder.buildLoginScreenViewController()
    viewController.modalPresentationStyle = .fullScreen
    navigationController?.pushViewController(viewController, animated: false)
    tabBarController?.tabBar.isHidden = true
  }
}
