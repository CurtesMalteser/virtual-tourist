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

    // TODO save inserted pins
    // TODO populate the map with stored pins

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        travelLocationsMap.addGestureRecognizer(longPressRecogniser)

        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()

        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            print("result \(result)")
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
        let annotations: MKPointAnnotation = MKPointAnnotation()
        annotations.coordinate = coordinates
        mapView.addAnnotation(annotations)
    }

    private func initLongPressGestureRecognizer() -> UILongPressGestureRecognizer {
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        return longPressRecogniser
    }
}

