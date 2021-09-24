//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Dmitry on 18.09.2021.
//

import UIKit

class ProfileViewController: UIViewController {
  
  private let profileView = ProfileView()
  private let data = ["Log Out"]
  private let presenter: ProfileViewPresenterProtocol
  
  init(presenter: ProfileViewPresenterProtocol) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    self.view = profileView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    profileView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    profileView.tableView.delegate = self
    profileView.tableView.dataSource = self
  }
}
//MARK: - DataSource, Delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = data[indexPath.row]
    cell.textLabel?.textAlignment = .center
    cell.textLabel?.textColor = .red
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    present(presenter.viewDidLogout(), animated: true)
  }
}
//MARK: - PresenterProtocol
extension ProfileViewController: ProfileViewProtocol {
  func sucessLogout() {
    let vc = MessengerBuilder.buildTabBar()
    vc.modalPresentationStyle = .fullScreen
    present(vc, animated: true)
  }
  
  
}
