//
//  PhotosController.swift
//  Virtual Tourist
//
//  Created by António Bastião on 27.12.20.
//

import Foundation

class PhotosController {

    private var _virtualTouristAPI: VirtualTouristAPI!
    private var _dataController: DataController!

    init(virtualTouristAPI: VirtualTouristAPI, dataController: DataController) {
        _virtualTouristAPI = virtualTouristAPI
        _dataController = dataController
    }

    func fetchPhotoForSize(photo: Photo) {
        _virtualTouristAPI.executeFetchPhotoDataTask(url: photo.photoURL!,
                successHandler: { (data: Data) in

                    let backgroundContext = self._dataController.backgroundContext
                    backgroundContext.perform {
                        do {
                            photo.photo = data
                            try backgroundContext.save()
                        } catch {
                            // todo handle with meaningful info to the user
                            print("get photo error \(error)")
                        }
                    }
                }, errorHandler: { error in
            print(error)
        })
    }

    func fetchPhotosForPin(pin: Pin, apiKey: String) {
        _virtualTouristAPI.executeDataTask(url: Endpoint.searchPhotoForCoordinates(apiKey: apiKey,
                latitude: pin.latitude,
                longitude: pin.longitude).url,
                successHandler: {
                    (photosSearch: PhotosSearch) in

                    photosSearch.photos.photoListResponse?.forEach({ photoResponse in

                        let url = Endpoint
                                .fetchPhotoURLs(apiKey: apiKey, photoResponse: photoResponse)
                                .url

                        self._virtualTouristAPI.executeDataTask(url: url,
                                successHandler: { (photoSizeResponse: PhotoSizeResponse) in

                                    let largeSize: PhotoSize = photoSizeResponse.sizes!.photoSize.first { size in
                                        size.size == PhotoSizeEnum.large
                                    } ?? photoSizeResponse.sizes!.photoSize.last!

                                    let backgroundContext = self._dataController.backgroundContext
                                    backgroundContext.perform {

                                        let backgroundPin = backgroundContext.object(with: pin.objectID) as! Pin
                                        do {
                                            let photo = Photo(context: backgroundContext)
                                            photo.pin = backgroundPin
                                            photo.photoID = photoResponse.id
                                            photo.photoURL = URL(string: largeSize.photoURL)
                                            photo.photo = nil

                                            try backgroundContext.save()
                                        } catch {
                                            // todo handle with meaningful info to the user
                                            print("get photo error \(error)")
                                        }
                                    }
                                }, errorHandler: { error in
                            print(error)
                        })
                    })
                },
                errorHandler: { error in
                    print(error)
                })
    }

    deinit {
        _virtualTouristAPI = nil
        _dataController = nil
    }

}