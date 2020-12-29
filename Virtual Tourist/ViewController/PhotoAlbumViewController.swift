//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by António Bastião on 02.12.20.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var photosCollectionView: UICollectionView!

    @IBOutlet weak var btnNewCollection: UIButton!

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    @IBAction func actionNewCollection(_ sender: Any) {
        fetchPhotosForPin()
    }

    static let identifier: String = "PhotoAlbumViewController"

    var pin: Pin!
    var dataController: DataController!
    var photosController: PhotosController!

    var fetchedResultsController: NSFetchedResultsController<Photo>!

    lazy var context = fetchedResultsController.managedObjectContext

    lazy var apiKey: String = (UIApplication.shared.delegate as! AppDelegate).apiKey

    override func viewDidLoad() {
        super.viewDidLoad()

        setCollectionViewCellDimensions(photosCollectionView)

        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self

        setupMapView(pin)

    }

    private func setupMapView(_ pin: Pin) {
        let coordinates = CLLocationCoordinate2D(
                latitude: pin.latitude,
                longitude: pin.longitude)

        let camera = mapView.camera
        camera.centerCoordinate = coordinates
        mapView.setCamera(camera, animated: false)

        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false

        mapView.addPinToMap(coordinates: coordinates)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initFetchPhotosController()
    }

    override func viewDidDisappear(_ animated: Bool) {
        fetchedResultsController = nil
        super.viewDidDisappear(animated)
    }

    /**
     Initializes the fetchedResultsController and fetch the Photo's for Pin.
    */
    private func initFetchPhotosController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoID", ascending: false)]

        fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: dataController.viewContext,
                sectionNameKeyPath: nil,
                cacheName: "\(pin.latitude)-\(pin.longitude)"
        )

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Could not perform fetch: \n\(error.localizedDescription)")
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell

        let photoEntry = fetchedResultsController.object(at: indexPath)

        if let photo = photoEntry.photo {
            cell.imageView.image = UIImage(data: photo)
        } else {
            cell.imageView.image = UIImage.imagePlaceholder()
            photosController.fetchPhotoForSize(photo: photoEntry)
        }

        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        fetchedResultsController.sections?.count ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let photosCount = fetchedResultsController.sections?[0].numberOfObjects ?? 0

        if (photosCount == 0) {
            fetchPhotosForPin()
        }

        return photosCount
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhoto(at: indexPath)
    }

    // measures the width of the view passed as param and divides it by the number of cells per row
    private func setCollectionViewCellDimensions(_ view: UIView) {

        let space: CGFloat = 3
        let numberOfItemsPerRow: CGFloat = 3

        let dimension = (view.frame.size.width - (space * (numberOfItemsPerRow - 1))) / numberOfItemsPerRow

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }

    private func deletePhoto(at indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        context.delete(photoToDelete)
        try? context.save()
    }

    private func fetchPhotosForPin() {
        photosController.fetchPhotosForPin(pin: pin, apiKey: apiKey)
    }

}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        photosCollectionView.reloadData()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            photosCollectionView.insertItems(at: [newIndexPath!])
        case .delete:
            photosCollectionView.deleteItems(at: [indexPath!])
        case .update:
            photosCollectionView.reloadItems(at: [indexPath!])
        @unknown default:
            break
        }
    }
}
