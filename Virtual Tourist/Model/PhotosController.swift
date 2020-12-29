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
    private var _isInProgress: Bool = false

    init(virtualTouristAPI: VirtualTouristAPI, dataController: DataController) {
        _virtualTouristAPI = virtualTouristAPI
        _dataController = dataController
        _backgroundContext = _dataController.backgroundContext
    }

    func fetchPhotoForSize(photo: Photo) {
        _virtualTouristAPI.executeFetchPhotoDataTask(url: photo.photoURL!,
                successHandler: { (data: Data) in
                    self._backgroundContext.perform {
                        do {
                            photo.photo = data
                            try self._backgroundContext.save()
                        } catch {
                            // todo handle with meaningful info to the user
                            print("get photo error \(error)")
                        }
                    }
                }, errorHandler: { error in
            print(error)
        })
    }

    func fetchPhotosForPin(pin: Pin, apiKey: String, isNewCollection: Bool) {

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

                    forEachPhotoFetchURL(photosSearch: photosSearch, apiKey: apiKey, backgroundContext: _backgroundContext, backgroundPin: backgroundPin)
                },

                errorHandler: { error in
                    self._isInProgress = false
                    print(error)
                })
    }

    private func forEachPhotoFetchURL(photosSearch: PhotosSearch, apiKey: String, backgroundContext: NSManagedObjectContext, backgroundPin: Pin) -> ()? {

        photosSearch.photos.photoListResponse?.forEach({ photoResponse in

            let lastPhoto = photosSearch.photos.photoListResponse!.last!

            let url = Endpoint
                    .fetchPhotoURLs(apiKey: apiKey, photoResponse: photoResponse)
                    .url

            _virtualTouristAPI.executeDataTask(url: url,
                    successHandler: { (photoSizeResponse: PhotoSizeResponse) in

                        let largeSize: PhotoSize = photoSizeResponse.sizes!.photoSize.first { size in
                            size.size == PhotoSizeEnum.large
                        } ?? photoSizeResponse.sizes!.photoSize.last!

                        backgroundContext.perform {

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

                        if (lastPhoto.id == photoResponse.id) {
                            self._isInProgress = false
                        }
                    }, errorHandler: { error in
                self._isInProgress = false

                print(error)
            })
        })
    }

    deinit {
        _virtualTouristAPI = nil
        _dataController = nil
        _backgroundContext = nil
    }

}