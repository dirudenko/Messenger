//
//  Location.swift
//  Messenger
//
//  Created by Dmitry on 26.10.2021.
//

import Foundation
import MessageKit
import CoreLocation

struct Location: LocationItem {
  var location: CLLocation
  var size: CGSize
}
