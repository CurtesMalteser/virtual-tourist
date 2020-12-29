//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by António Bastião on 30.11.20.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var travelLocationsMap: MKMapView!

    private lazy var longPressRecogniser: UILongPressGestureRecognizer = initLongPressGestureRecognizer()

    var dataController: DataController!

    var fetchedResultsController: NSFetchedResultsController<Pin>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        travelLocationsMap.delegate = self
        travelLocationsMap.addGestureRecognizer(longPressRecogniser)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initFetchPinsController()
    }

    private func initFetchPinsController() {

        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "objectID", ascending: false)]

        fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: dataController.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
        )

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Could not perform fetch:\n\(error.localizedDescription)")
        }

        fetchedResultsController.fetchedObjects?.forEach { pin in
            travelLocationsMap.addPinToMap(
                    coordinates: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        fetchedResultsController = nil
        super.viewDidDisappear(animated)
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

        addPinPointAnnotation(mapView: travelLocationsMap, coordinates: touchMapCoordinate)
    }

    private func addPinPointAnnotation(mapView: MKMapView, coordinates: CLLocationCoordinate2D) {

        let pin = Pin(context: fetchedResultsController.managedObjectContext)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude

        do {
            try fetchedResultsController.managedObjectContext.save()
        } catch {
            print("Failed save addPinPointAnnotation!")
        }

    }

    private func initLongPressGestureRecognizer() -> UILongPressGestureRecognizer {
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.6
        return longPressRecogniser
    }

    private func pushPhotoAlbumViewController(pin: Pin) {

        pushViewControllerWithInject(storyboard: storyboard,
                identifier: PhotoAlbumViewController.identifier,
                navigationController: navigationController) { viewController in
            let photoAlbumViewController = viewController as! PhotoAlbumViewController
            photoAlbumViewController.pin = pin
            photoAlbumViewController.dataController = self.dataController
            photoAlbumViewController.photosController = PhotosController(virtualTouristAPI: VirtualTouristAPI(), dataController: self.dataController)
        }

    }

}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard annotation is MKPointAnnotation else {
            return nil
        }

        let identifier = "Annotation"
        let dequeueReusableAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if let annotationView = dequeueReusableAnnotationView {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let image = UIImage(named: "ImagePlaceholder")

            let button = UIButton(type: .infoLight)
            button.setImage(image, for: .normal)

            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = button

            return annotationView
        }

    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        let latitude = view.annotation?.coordinate.latitude
        let longitude = view.annotation?.coordinate.longitude

        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()

        let subPredicates = [
            NSPredicate(format: "latitude == %@", String(latitude!)),
            NSPredicate(format: "longitude == %@", String(longitude!))
        ]

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)

        let pin = try? fetchedResultsController.managedObjectContext.fetch(fetchRequest).first

        pushPhotoAlbumViewController(pin: pin!)

    }

}

extension MapViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if (type == .insert) {
            if let pin = controller.object(at: newIndexPath!) as? Pin {
                travelLocationsMap.addPinToMap(coordinates: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
            }
        }
    }

}
