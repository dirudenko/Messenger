//
//  TabBarViewController.swift
//  Messenger
//
//  Created by Dmitry on 18.09.2021.
//

import UIKit

class TabBarViewController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    UITabBar.appearance().barTintColor = .systemBackground
    tabBar.tintColor = .label
    setupVCs()
  }
  
  func setupVCs() {
    viewControllers = [
      createNavController(for: MessengerBuilder.buildConversationsViewController(), title: NSLocalizedString("Chats", comment: ""), image: UIImage(systemName: "message")!),
      createNavController(for: MessengerBuilder.buildProfileViewController(), title: NSLocalizedString("Profile", comment: ""), image: UIImage(systemName: "gearshape")!)
      
    ]
  }
  
  
  private func createNavController(for rootViewController: UIViewController,
                                   title: String,
                                   image: UIImage) -> UIViewController {
    let navController = UINavigationController(rootViewController: rootViewController)
    navController.tabBarItem.title = title
    navController.tabBarItem.image = image
    navController.navigationBar.prefersLargeTitles = true
    rootViewController.navigationItem.title = title
    return navController
  }
}
