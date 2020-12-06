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

    var fetchedResultsController: NSFetchedResultsController<Photo>!

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
        initFetchPhotosResults()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }

    private func initFetchPhotosResults() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()

        let subPredicates = [
            NSPredicate(format: "pin == %@", pin),
        ]

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoID", ascending: false)]

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
            fatalError("Could not perform fetch: \n\(error.localizedDescription)")
        }
    }

    private func fetchPhotosForPin() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let apiKey = appDelegate.apiKey


        VirtualTouristAPI.executeDataTask(url: Endpoint.searchPhotoForCoordinates(apiKey: apiKey,
                latitude: pin.latitude,
                longitude: pin.longitude).url,
                successHandler: {
                    (photosSearch: PhotosSearch) in

                    photosSearch.photos.photoListResponse?.forEach({ photoResponse in

                        let url = Endpoint
                                .fetchPhotoURLs(apiKey: apiKey, photoResponse: photoResponse)
                                .url

                        VirtualTouristAPI.executeDataTask(url: url,
                                successHandler: { (photoSizeResponse: PhotoSizeResponse) in

                                    let largeSize: PhotoSize = photoSizeResponse.sizes!.photoSize.first { size in
                                        size.size == PhotoSizeEnum.large
                                    } ?? photoSizeResponse.sizes!.photoSize.last!


                                    VirtualTouristAPI.executeDataDataTask(url: URL(string: largeSize.photoURL)!,
                                            successHandler: { (data: Data) in

                                                do {
                                                    let photo = Photo(context: self.dataController.viewContext)
                                                    photo.pin = self.pin
                                                    photo.photoID = photoResponse.id
                                                    photo.photoURL = url
                                                    photo.photo = data

                                                    try self.dataController.viewContext.save()
                                                } catch {
                                                    // todo handle with meaningful info to the user
                                                    print("get photo error \(error)")
                                                }
                                            }, errorHandler: { error in
                                        print(error)
                                    })
                                }, errorHandler: { error in
                            print(error)
                        })
                    })
                },
                errorHandler: {
                    error in
                    print(error)
                })
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell

        let photoEntry = fetchedResultsController.object(at: indexPath)

        if let photo = photoEntry.photo {
            cell.imageView.image = UIImage(data: photo)
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
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
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
            break // handle the update by replacing images placeholder
        @unknown default:
            break
        }
    }
}
