//
//  PhotosController.swift
//  Virtual Tourist
//
//  Created by António Bastião on 27.12.20.
//

import Foundation
import CoreData

class PhotosController {

    private var _virtualTouristAPI: VirtualTouristAPI!
    private var _dataController: DataController!
    private var _backgroundContext: NSManagedObjectContext!
    // used to avoid double API calls
    private var _isInProgress: Bool = false

    init(virtualTouristAPI: VirtualTouristAPI, dataController: DataController) {
        _virtualTouristAPI = virtualTouristAPI
        _dataController = dataController
        _backgroundContext = _dataController.backgroundContext
    }

    func fetchPhotoForSize(photo: Photo) {
        _virtualTouristAPI.executeFetchPhotoDataTask(url: photo.photoURL!,
                successHandler: { (data: Data) in
                    self._backgroundContext.doTry(onSuccess: { context in

                        let backgroundPhoto = context.object(with: photo.objectID) as! Photo
                        backgroundPhoto.photo = data

                        try context.save()

                    }, onError: { error in
                        print("executeFetchPhotoDataTask save photo error \(error)")
                    })
                }, errorHandler: { error in
            if let error = error {
                print("executeFetchPhotoDataTask error \(error)")
            }
        })
    }

    func fetchPhotosForPin(pin: Pin, apiKey: String, isNewCollection: Bool, completionHandler: @escaping (_ status: Status) -> Void) {

        if (_isInProgress) {
            return
        }

        _isInProgress = true

        var page: Int? = nil
        if (isNewCollection) {
            var newPage: Int = 0
            if pin.pages > 1 {
                repeat {
                    newPage = Int.random(in: 1...Int(pin.pages))
                    page = newPage
                } while newPage == pin.currentPage
            }
        }

        _virtualTouristAPI.executeDataTask(url: Endpoint.searchPhotoForCoordinates(apiKey: apiKey,
                latitude: pin.latitude,
                longitude: pin.longitude,
                page: page).url,
                successHandler: { [self] (photosSearch: PhotosSearch) in

                    let backgroundPin = _backgroundContext.object(with: pin.objectID) as! Pin

                    backgroundPin.pages = Int64(photosSearch.photos.pages)
                    backgroundPin.currentPage = Int64(photosSearch.photos.page)

                    if let photoListResponse = photosSearch.photos.photoListResponse {
                        if (photoListResponse.isEmpty) {
                            completionHandler(Status.noData)
                            _isInProgress = false
                        } else {
                            forEachPhotoFetchURL(photosSearch: photosSearch,
                                    apiKey: apiKey,
                                    backgroundContext: _backgroundContext,
                                    backgroundPin: backgroundPin,
                                    completionHandler: completionHandler)

                        }
                    }
                }, errorHandler: { _ in
            self._isInProgress = false
            completionHandler(Status.error)
        })
    }

    private func forEachPhotoFetchURL(photosSearch: PhotosSearch,
                                      apiKey: String,
                                      backgroundContext: NSManagedObjectContext,
                                      backgroundPin: Pin,
                                      completionHandler: @escaping (_ status: Status) -> Void) {

        let lastPhoto = photosSearch.photos.photoListResponse!.last!

        photosSearch.photos.photoListResponse?.forEach({ photoResponse in

            let url = Endpoint
                    .fetchPhotoURLs(apiKey: apiKey, photoResponse: photoResponse)
                    .url

            _virtualTouristAPI.executeDataTask(url: url,
                    successHandler: { [self] (photoSizeResponse: PhotoSizeResponse) in

                        let largeSize: PhotoSize = photoSizeResponse.sizes!.photoSize.first { size in
                            size.size == PhotoSizeEnum.large
                        } ?? photoSizeResponse.sizes!.photoSize.last!

                        backgroundContext.doTry(onSuccess: { context in

                            initializePhoto(context: context, backgroundPin: backgroundPin, photoResponse: photoResponse, largeSize: largeSize)

                            try context.save()

                            if (lastPhoto.id == photoResponse.id) {
                                _isInProgress = false
                                completionHandler(Status.success)
                            }

                        }, onError: { error in
                            if (lastPhoto.id == photoResponse.id) {
                                _isInProgress = false
                                completionHandler(Status.success)
                            }
                        })

                    }, errorHandler: { _ in
                if (lastPhoto.id == photoResponse.id) {
                    self._isInProgress = false
                }
            })
        })
    }

    private func initializePhoto(context: NSManagedObjectContext, backgroundPin: Pin, photoResponse: PhotoResponse, largeSize: PhotoSize) {
        let photo = Photo(context: context)
        photo.pin = backgroundPin
        photo.photoID = photoResponse.id
        photo.photoURL = URL(string: largeSize.photoURL)
        photo.photo = nil
    }

    deinit {
        _virtualTouristAPI = nil
        _dataController = nil
        _backgroundContext = nil
    }

}