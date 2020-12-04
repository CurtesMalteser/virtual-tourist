//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by António Bastião on 02.12.20.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController {

    static let identifier: String = "PhotoAlbumViewController"
    var pin: Pin!
    var dataController: DataController!
    var photosArray: [Photo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()

        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            if (result.count > 0) {
                photosArray = result
                print("photosArray \(photosArray.count)")
            }
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let apiKey = appDelegate.apiKey


        VirtualTouristAPI.executeDataTask(url: Endpoint.searchPhotoForCoordinates(apiKey: apiKey,
                latitude: pin.latitude,
                longitude: pin.longitude).url,
                successHandler: {
                    (photosSearch: PhotosSearch) in

                    print("photosSearch \(photosSearch)")

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
}
