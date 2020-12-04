//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by António Bastião on 02.12.20.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
   
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    @IBOutlet weak var btnNewCollection: UIButton!
    
    @IBAction func actionNewCollection(_ sender: Any) {
    }
    
    static let identifier: String = "PhotoAlbumViewController"
    var pin: Pin!
    var dataController: DataController!

    override func viewDidLoad() {
        super.viewDidLoad()

        photosCollectionView.delegate = self

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let apiKey = appDelegate.apiKey

        VirtualTouristAPI.executeDataTask(url: Endpoint.searchPhotoForCoordinates(apiKey: apiKey,
                latitude: pin.latitude,
                longitude: pin.longitude).url,
                successHandler: {
                    (photosSearch: PhotosSearch) in

                    print("photosSearch \(photosSearch)")

                    photosSearch.photos.photo.forEach({ photo in

                        let url = Endpoint
                                .fetchPhotoURLs(apiKey: apiKey, photoResponse: photo)
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

    private func refreshCollectionView() {
        photosCollectionView.reloadData()
    }

}
