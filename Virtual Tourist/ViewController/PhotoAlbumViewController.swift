//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by António Bastião on 02.12.20.
//

import UIKit

class PhotoAlbumViewController: UIViewController {

    static let identifier: String = "PhotoAlbumViewController"
    var pin: Pin!
    var dataController: DataController!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let apiKey = appDelegate.apiKey

        VirtualTouristAPI.executeDataTask(url: Endpoint.searchPhotoForCoordinates(apiKey: apiKey,
                latitude: pin.latitude,
                longitude: pin.longitude).url,
                successHandler: {
                    (data: PhotosSearch) in

                    print("data \(data)")

                },
                errorHandler: {
                    error in
                    print(error)
                })
    }
}
