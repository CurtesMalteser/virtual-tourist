//
//  Pin+CLPlacemark.swift
//  Virtual Tourist
//
//  Created by António Bastião on 29.12.20.
//

import Foundation
import CoreLocation

extension Pin {

    private func formatCoordinate(coordinate: Double) -> String {
        String(format: "%.2f", coordinate)
    }

    func setAddressOnPlacemarkError() {
        address = "lat: \(formatCoordinate(coordinate: latitude)) - long: \(formatCoordinate(coordinate: longitude))"
    }

    func setAddressFromPlaceMark(_ placemark: CLPlacemark) {
        if ((placemark.name) != nil) {
            address = placemark.name
        } else if ((placemark.areasOfInterest) != nil) {
            address = placemark.areasOfInterest?.first
        } else if ((placemark.inlandWater) != nil) {
            address = placemark.inlandWater
        } else if ((placemark.locality) != nil) {
            address = placemark.locality
        } else if ((placemark.administrativeArea) != nil) {
            address = placemark.administrativeArea
        } else if ((placemark.country) != nil) {
            address = placemark.country
        } else {
            setAddressOnPlacemarkError()
        }
    }
}
