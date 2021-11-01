//
//  PhotoViewerView.swift
//  Messenger
//
//  Created by Dmitry on 11.10.2021.
//

import UIKit

class PhotoViewerView: UIView {
  
  private let imageSize: CGFloat = 200
  
  private(set) lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }
  
  private func configure() {
    backgroundColor = .black
    addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      imageView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
      imageView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
      imageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
    ])
  }
}
