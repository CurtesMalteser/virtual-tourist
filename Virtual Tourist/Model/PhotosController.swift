//
//  PhotosController.swift
//  Virtual Tourist
//
//  Created by António Bastião on 27.12.20.
//

import Foundation

class PhotosController {

    private let virtualTouristAPI: VirtualTouristAPI
    private let dataController: DataController

    init(virtualTouristAPI: VirtualTouristAPI, dataController: DataController) {
        self.virtualTouristAPI = virtualTouristAPI
        self.dataController = dataController
    }


    func fetchPhotoForSize(photo: Photo) -> URLSessionDataTask {
        virtualTouristAPI.executeFetchPhotoDataTask(url: photo.photoURL!,
                successHandler: { (data: Data) in

                    let backgroundContext = self.dataController.backgroundContext
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

}