//
//  LocationPickerViewController.swift
//  Messenger
//
//  Created by Dmitry on 26.10.2021.
//

import UIKit
import CoreLocation
import MapKit

class LocationPickerViewController: UIViewController {
  
  var complition: ((CLLocationCoordinate2D) ->(Void))?
  
  private var isPickable = true
  private var coordinates: CLLocationCoordinate2D?
  private let map: MKMapView = {
    let map  = MKMapView()
    return map
  }()
  
  init(coordinates: CLLocationCoordinate2D?) {
    self.coordinates = coordinates
    if coordinates != nil {
      self.isPickable = false
    }
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(map)
    if isPickable {
      map.isUserInteractionEnabled = true
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отправить",
                                                          style: .done,
                                                          target: self,
                                                          action: #selector(sendButtonPressed))
      let gesture = UITapGestureRecognizer(target: self,
                                           action: #selector(didTapMap(_:)))
      gesture.numberOfTouchesRequired = 1
      gesture.numberOfTapsRequired = 1
      map.addGestureRecognizer(gesture)
    } else {
      guard let coordinates = coordinates else {
        return
      }
      let region = map.regionThatFits(MKCoordinateRegion(center: coordinates, latitudinalMeters: 200, longitudinalMeters: 200))
      map.setRegion(region, animated: true)
      let pin = MKPointAnnotation()
      pin.coordinate = coordinates
      map.addAnnotation(pin)
    }
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    map.frame = view.bounds
  }
  
  @objc func sendButtonPressed() {
    guard let coordinates = coordinates else {
      return
    }
    navigationController?.popViewController(animated: true)
    complition?(coordinates)
  }
  
  @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: map)
    let coordinates = map.convert(location, toCoordinateFrom: map)
    self.coordinates = coordinates
    map.annotations.forEach { map.removeAnnotation($0) }
    let pin = MKPointAnnotation()
    pin.coordinate = coordinates
    map.addAnnotation(pin)
  }
}
