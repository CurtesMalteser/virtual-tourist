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

    private lazy var postLocationErrorMessage = """
                                                Couldn't add new location.
                                                Please try again.
                                                """

    private lazy var fetchPinForSegueErrorMessage = """
                                                    Couldn't find Pin for location.
                                                    Please try again.
                                                    """

    var dataController: DataController!

    var fetchedResultsController: NSFetchedResultsController<Pin>!

    override func viewDidLoad() {
        super.viewDidLoad()
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
                cacheName: "MapViewController"
        )

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Could not perform fetch:\n\(error.localizedDescription)")
        }

        fetchedResultsController.fetchedObjects?.forEach { pin in
            travelLocationsMap.addPinToMap(pin)
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

        addPinPointAnnotation(coordinates: touchMapCoordinate)
    }

    private func addPinPointAnnotation(coordinates: CLLocationCoordinate2D) {

        showNetworkActivityAlert { [self] networkActivityIndicator in

            let latitude = coordinates.latitude
            let longitude = coordinates.longitude

            func storePinOnResult() {
                fetchedResultsController.managedObjectContext.doTry(onSuccess: { context in
                    try context.save()
                    networkActivityIndicator.dismiss(animated: false, completion: nil)
                }, onError: { _ in
                    showErrorAlert(message: postLocationErrorMessage)
                })
            }

            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude),
                    completionHandler: { placemarks, error in

                        let pin = Pin(context: fetchedResultsController.managedObjectContext)
                        pin.latitude = latitude
                        pin.longitude = longitude

                        if (error != nil) {
                            pin.setAddressOnPlacemarkError()
                            storePinOnResult()
                        }

                        let placemark = placemarks?.first
                        if let mark = placemark {
                            pin.setAddressFromPlaceMark(mark)
                            storePinOnResult()
                        }

                    })
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
            photoAlbumViewController.dataController = dataController
            photoAlbumViewController.photosController = PhotosController(virtualTouristAPI: VirtualTouristAPI(), dataController: dataController)
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
            let btnImage = UIImage.imagePlaceholder()

            let button = UIButton(type: .infoLight)
            button.setImage(btnImage, for: .normal)

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

        fetchedResultsController.managedObjectContext.doTry(
                onSuccess: { context in
                    if let pin = try context.fetch(fetchRequest).first {
                        pushPhotoAlbumViewController(pin: pin)
                    } else {
                        showErrorAlert(message: fetchPinForSegueErrorMessage)
                    }
                },
                onError: { _ in
                    showErrorAlert(message: fetchPinForSegueErrorMessage)
                }
        )
    }

}

extension MapViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if (type == .insert) {
            if let pin = controller.object(at: newIndexPath!) as? Pin {
                travelLocationsMap.addPinToMap(pin)
            }
        }
    }

}
