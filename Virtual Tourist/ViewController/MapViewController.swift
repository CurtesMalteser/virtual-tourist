//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by António Bastião on 30.11.20.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var travelLocationsMap: MKMapView!

    private lazy var longPressRecogniser: UILongPressGestureRecognizer = initLongPressGestureRecognizer()

    var dataController: DataController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        travelLocationsMap.addGestureRecognizer(longPressRecogniser)

        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()

        // TODO: wrap in try catch
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            if (result.count > 0) {
                result.forEach { pin in
                    addPinToMap(
                            coordinates: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude),
                            mapView: travelLocationsMap)
                }
            }
        }

    }

    deinit {
        travelLocationsMap.removeGestureRecognizer(longPressRecogniser)
    }

    @objc private func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .began {
            return
        }

        let touchPoint = gestureRecognizer.location(in: travelLocationsMap)
        let touchMapCoordinate: CLLocationCoordinate2D = travelLocationsMap.convert(touchPoint, toCoordinateFrom: travelLocationsMap)

        addStudentsPointAnnotation(mapView: travelLocationsMap, coordinates: touchMapCoordinate)
    }

    private func addStudentsPointAnnotation(mapView: MKMapView, coordinates: CLLocationCoordinate2D) {

        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude


        do {
            try dataController.viewContext.save()
            addPinToMap(coordinates: coordinates, mapView: mapView)
        } catch {
            // todo handle with meaningful info to the user
        }

    }

    // TODO: store the CLLocationCoordinate2D instead of lat and long
    private func addPinToMap(coordinates: CLLocationCoordinate2D, mapView: MKMapView) {
        let annotations: MKPointAnnotation = MKPointAnnotation()
        annotations.coordinate = coordinates
        mapView.addAnnotation(annotations)
    }

    // Unused and added to be used on next VC
    private func deletePin(pin: Pin) {

        dataController.viewContext.delete(pin)

        do {
            try dataController.viewContext.save()

        } catch {
            // todo handle with meaningful info to the user
        }
    }

    private func initLongPressGestureRecognizer() -> UILongPressGestureRecognizer {
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        return longPressRecogniser
    }
}
