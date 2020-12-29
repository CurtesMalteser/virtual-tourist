//
//  MKMapViewExtension+AddPin.swift
//  Virtual Tourist
//
//  Created by António Bastião on 06.12.20.
//

import MapKit

extension MKMapView {

    func addPinToMap(_ pin: Pin) {
        let annotation: MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)

        if let address = pin.address {
            annotation.title = address
        } else {
            pin.setAddressOnPlacemarkError()
            annotation.title = pin.address
        }

        addAnnotation(annotation)
    }

}
