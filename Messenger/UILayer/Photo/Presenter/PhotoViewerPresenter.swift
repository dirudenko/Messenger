//
//  PhotoViewerPresenter.swift
//  Messenger
//
//  Created by Dmitry on 11.10.2021.
//

import UIKit

protocol PhotoViewerProtocol: AnyObject {
  
}

protocol PhotoViewerPresenterProtocol: AnyObject {
  
}

class PhotoViewerPresenter: PhotoViewerPresenterProtocol {
  weak var view: (UIViewController & PhotoViewerProtocol)?

}
