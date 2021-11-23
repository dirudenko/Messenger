//
//  UIViewController+Ext.swift
//  Messenger
//
//  Created by Dmitry on 23.11.2021.
//

import UIKit

fileprivate var containerView: UIView!

extension UIViewController {
  
  func presentAlert(title: String, message: String) {
          DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
          }
      }
  
  func showLoadingView() {
          containerView = UIView(frame: view.bounds)
          view.addSubview(containerView)
          
          containerView.backgroundColor   = .systemBackground
          containerView.alpha             = 0
          
          UIView.animate(withDuration: 0.25) { containerView.alpha = 0.8 }
          
          let activityIndicator = UIActivityIndicatorView(style: .large)
          containerView.addSubview(activityIndicator)
          
          activityIndicator.translatesAutoresizingMaskIntoConstraints = false
          
          NSLayoutConstraint.activate([
              activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
              activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
          ])
          
          activityIndicator.startAnimating()
      }
      
      
      func dismissLoadingView() {
    
          DispatchQueue.main.async {
           //   containerView.removeFromSuperview()
              containerView = nil
          }
      }

  
}
