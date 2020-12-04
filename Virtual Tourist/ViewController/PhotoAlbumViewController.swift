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

    var photosResponseArray: [PhotoResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()

        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            if (result.count > 0) {
                photosArray = result
                print("photosArray \(photosArray.count)")
            }
        }

        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let apiKey = appDelegate.apiKey


        VirtualTouristAPI.executeDataTask(url: Endpoint.searchPhotoForCoordinates(apiKey: apiKey,
                latitude: pin.latitude,
                longitude: pin.longitude).url,
                successHandler: {
                    (photosSearch: PhotosSearch) in

                    DispatchQueue.main.async {
                        self.refreshCollectionView(photosResponse: photosSearch.photos.photo)
                    }


                    photosSearch.photos.photo.forEach({ photoResponse in

                        let url = Endpoint
                                .fetchPhotoURLs(apiKey: apiKey, photoResponse: photoResponse)
                                .url


                        print("url \(url)")

                        VirtualTouristAPI.executeDataTask(url: url,
                                successHandler: { (photoSizeResponse: PhotoSizeResponse) in

                                    print("photoSizeResponse \(photoSizeResponse)")

                                    let largeSize: PhotoSize = photoSizeResponse.sizes.photoSize.first { size in
                                        size.size == PhotoSizeEnum.large
                                    } ?? photoSizeResponse.sizes.photoSize.last!


                                    VirtualTouristAPI.executeDataDataTask(url: URL(string: largeSize.url)!,
                                            successHandler: { (data: Data) in
                                                print("photoData: \(data)")


                                                let photo = Photo(context: self.dataController.viewContext)
                                                photo.photoID = photoResponse.id
                                                photo.photoURL = url
                                                photo.photo = data

                                                do {
                                                    try self.dataController.viewContext.save()
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

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photosResponseArray.count
    }


    private func refreshCollectionView(photosResponse: [PhotoResponse]) {
        photosResponseArray = photosResponse
        print("photosResponseArray \(photosResponseArray.count)")
        photosCollectionView.reloadData()
    }

}
