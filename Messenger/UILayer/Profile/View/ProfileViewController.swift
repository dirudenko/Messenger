//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Dmitry on 18.09.2021.
//

import UIKit

class ProfileViewController: UIViewController {
  
  private let profileView = ProfileView()
  private var data = [ProfileModel]()
  private let presenter: ProfileViewPresenterProtocol
  private var isFetched = false
  
  init(presenter: ProfileViewPresenterProtocol) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    view = profileView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addUserInformation()
    profileView.tableView.delegate = self
    profileView.tableView.dataSource = self
  }
  
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  //  addUserInformation()
   // profileView.tableView.reloadData()
  }
  
  private func addUserInformation() {
    let userName = UserDefaults.standard.value(forKey: "name") as? String
    data.append(ProfileModel(viewProfileType: .info,
                             title:"Имя: \(userName ?? "Без имени")",
                             handler: nil))
    
    let userEmail = UserDefaults.standard.value(forKey: "email") as? String
    data.append(ProfileModel(viewProfileType: .info,
                             title:"Почта: \(userEmail ?? "Почта не указана")",
                             handler: nil))
    
    guard let safeMail = userEmail?.safeEmail else { return }
    let fileName = safeMail + "_profile_picture.png"
    let path = "images/" + fileName
    presenter.downloadURL(for: path, image: profileView.photoImage)
    
    data.append(ProfileModel(viewProfileType: .logout,
                             title: "Выйти",
                             handler: { [weak self] in
      guard let self = self else { return }
      let vc = self.presenter.viewDidLogout()
      self.present(vc, animated: true)
    }))
  }
  
}
//MARK: - DataSource, Delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = profileView.tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as? ProfileTableViewCell else { return UITableViewCell()}
    let model = data[indexPath.row]
    cell.configure(with: model)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    data[indexPath.row].handler?()
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
