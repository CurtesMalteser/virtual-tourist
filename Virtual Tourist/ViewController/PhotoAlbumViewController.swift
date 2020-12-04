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

    @IBAction func actionNewCollection(_ sender: Any) {
    }

    static let identifier: String = "PhotoAlbumViewController"
    var pin: Pin!
    var dataController: DataController!
    var photosArray: [Photo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self

        fetchPhotosCollectionViewForPin(pin)

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

                                                print("get photo")
                                                let photo = Photo(context: self.dataController.viewContext)
                                                photo.photoID = photoResponse.id
                                                photo.photoURL = url
                                                photo.photo = data

                                                do {
                                                    try self.dataController.viewContext.save()
                                                    DispatchQueue.main.async {
                                                        self.photosArray.append(photo)
                                                        self.photosCollectionView.reloadData()
                                                    }
                                                } catch {
                                                    // todo handle with meaningful info to the user

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
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)


        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            if (result.count > 0) {
                self.photosArray = result
                photosCollectionView.reloadData()
            } else {
                fetchPhotosForPin()
            }
        }


    }

}
