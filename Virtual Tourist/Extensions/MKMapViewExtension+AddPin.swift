//
//  MKMapViewExtension+AddPin.swift
//  Virtual Tourist
//
//  Created by António Bastião on 06.12.20.
//

import MapKit

extension MKMapView {

    func addPinToMap(coordinates: CLLocationCoordinate2D) {
        let annotations: MKPointAnnotation = MKPointAnnotation()
        annotations.coordinate = coordinates
        addAnnotation(annotations)
    }

}
