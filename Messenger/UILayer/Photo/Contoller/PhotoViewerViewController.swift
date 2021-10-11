//
//  PhotoViewerViewController.swift
//  Messenger
//
//  Created by Dmitry on 11.10.2021.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {

  private let photoView = PhotoViewerView()
  private let presenter: PhotoViewerPresenterProtocol
  private let url: URL

  init(presenter: PhotoViewerPresenterProtocol, url: URL) {
    self.presenter = presenter
    self.url = url
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    self.view = photoView
    title = "Фото"
    navigationItem.largeTitleDisplayMode = .never
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      photoView.imageView.sd_setImage(with: url, completed: nil)
       
    }
}
    // MARK: - Navigation
extension PhotoViewerViewController: PhotoViewerProtocol {

}
