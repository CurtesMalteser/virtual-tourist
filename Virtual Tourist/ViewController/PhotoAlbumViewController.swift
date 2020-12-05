//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by António Bastião on 02.12.20.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
        NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var photosCollectionView: UICollectionView!

    @IBOutlet weak var btnNewCollection: UIButton!

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    @IBAction func actionNewCollection(_ sender: Any) {
    }

    static let identifier: String = "PhotoAlbumViewController"
    var pin: Pin!
    var dataController: DataController!
    var photosArray: [Photo] = []
    var fetchedResultsController: NSFetchedResultsController<Photo>!

    override func viewDidLoad() {
        super.viewDidLoad()

        setCollectionViewCellDimensions(photosCollectionView)

        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self

        fetchPhotosCollectionViewForPin(pin)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoID", ascending: true)]

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
            print("performFetch: \(error)")
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
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
                                    } ?? photoSizeResponse.sizes?.photoSize.last! as! PhotoSize


                                    VirtualTouristAPI.executeDataDataTask(url: URL(string: largeSize.photoURL)!,
                                            successHandler: { (data: Data) in

                                                DispatchQueue.main.async {
                                                    do {

                                                        print("pin \(self.pin)")
                                                        let photo = Photo(context: self.dataController.viewContext)
                                                        photo.pin = self.pin
                                                        photo.photoID = photoResponse.id
                                                        photo.photoURL = url
                                                        photo.photo = data
                                                        try self.dataController.viewContext.save()

                                                        self.photosArray.append(photo)
                                                        self.photosCollectionView.reloadData()

                                                    } catch {
                                                        // todo handle with meaningful info to the user
                                                        print("get photo error \(error)")

                                                    }

                                                }

                                            }, errorHandler: { error in

                                    }
                                    )

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

        if (photosArray.count > 0) {
            print("photosArray.count \(photosArray.count)")
            if let x = photosArray[(indexPath as IndexPath).row].photo {
                cell.imageView.image = UIImage(data: x)
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photosArray.count
    }


    private func fetchPhotosCollectionViewForPin(_ pin: Pin) {

        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()

        let subPredicates = [
            NSPredicate(format: "pin.latitude == %@", pin.latitude),
            NSPredicate(format: "pin.longitude == %@", pin.longitude),
        ]


        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subPredicates)

        fetchRequest.predicate = predicate


        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            if (result.count > 0) {
                print("read from db")
                self.photosArray = result
                photosCollectionView.reloadData()
            } else {
                print("fetch from api")
                fetchPhotosForPin()
            }
        }

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


}
