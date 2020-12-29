//
//  MKMapViewExtension+AddPin.swift
//  Virtual Tourist
//
//  Created by António Bastião on 06.12.20.
//

import MapKit

extension MKMapView {

    func addPinToMap(coordinates: CLLocationCoordinate2D) {
        let annotation: MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = "pin_label"
        addAnnotation(annotation)
    }

}
