//
//  Media.swift
//  Messenger
//
//  Created by Dmitry on 11.10.2021.
//

import UIKit
import MessageKit

struct Media: MediaItem {
  var url: URL?
  var image: UIImage?
  var placeholderImage: UIImage
  var size: CGSize
}
