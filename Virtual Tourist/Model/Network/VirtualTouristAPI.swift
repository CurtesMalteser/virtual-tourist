//
//  VirtualTouristAPI.swift
//  Virtual Tourist
//
//  Created by António Bastião on 03.12.20.
//

import Foundation

class VirtualTouristAPI {

    func executeDataTask<T: Codable>(url: URL, successHandler: @escaping (T) -> Void, errorHandler: @escaping (Error?) -> Void) {

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("no data")
                errorHandler(error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(T.self, from: data)
                successHandler(data)

            } catch {
                errorHandler(error)
            }

        }

        task.resume()
    }

    func executeFetchPhotoDataTask(url: URL, successHandler: @escaping (Data) -> Void, errorHandler: @escaping (Error?) -> Void) -> URLSessionDataTask {

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("no data")
                errorHandler(error)
                return
            }
            successHandler(data)
        }

        task.resume()

        return task
    }

}