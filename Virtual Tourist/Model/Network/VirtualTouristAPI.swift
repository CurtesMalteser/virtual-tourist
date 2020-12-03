//
//  VirtualTouristAPI.swift
//  Virtual Tourist
//
//  Created by António Bastião on 03.12.20.
//

import Foundation

class VirtualTouristAPI {

    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    class func executeDataTask<T: Decodable>(url: URL, successHandler: @escaping (T) -> Void, errorHandler: @escaping (Error?) -> Void) {

        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else {
                print("no data")
                return
            }

            let decoder = JSONDecoder()

            do {
                let data = try decoder.decode(T.self, from: data)
                successHandler(data)
            } catch {
                errorHandler(error)
            }

        }

        task.resume()
    }

}