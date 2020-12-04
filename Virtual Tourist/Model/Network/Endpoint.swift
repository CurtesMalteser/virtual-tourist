//
//  Endpoint.swift
//  Virtual Tourist
//
//  Created by António Bastião on 03.12.20.
//

import Foundation

struct Endpoint {
    var queryItems: [URLQueryItem] = []
}

extension Endpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.flickr.com"
        components.path = "/services/rest/"
        components.queryItems = queryItems

        guard let url = components.url else {
            preconditionFailure(
                    "Invalid URL components: \(components)"
            )
        }

        return url
    }
}

extension Endpoint {

    private static let method = "method"
    private static let methodSearchPhoto = "flickr.photos.search"
    private static let methodGetPhotoURL = "flickr.photos.getSizes"
    private static let apiKey = "api_key"
    private static let photoID = "photo_id"

    static func searchPhotoForCoordinates(apiKey key: String, latitude: Double, longitude: Double, radius: Int = 10, perPage: Int = 30) -> Self {

        let endpointQueryItems = [
            URLQueryItem(name: "lat",
                    value: String(latitude)),
            URLQueryItem(name: "lon",
                    value: String(longitude)),
            URLQueryItem(name: "radius",
                    value: String(radius)),
            URLQueryItem(
                    name: "per_page",
                    value: String(perPage)
            )
        ]

        let items = setMethodAndKeyAPI(method: methodSearchPhoto, apiKey: key, queryItems: endpointQueryItems)

        return Endpoint(
                queryItems: items)
    }

    static func fetchPhotoURLs(apiKey key: String, photoResponse photo: PhotoResponse) -> Self {

        let endpointQueryItems = [
            URLQueryItem(
                    name: method,
                    value: String(photo.id)
            )
        ]

        let items = setMethodAndKeyAPI(method: methodGetPhotoURL, apiKey: key, queryItems: endpointQueryItems)

        return Endpoint(
                queryItems: items

        )
    }

    private static func setMethodAndKeyAPI(method methodValue: String, apiKey key: String, queryItems: [URLQueryItem]) -> [URLQueryItem] {
        var items = [URLQueryItem(
                name: method,
                value: methodValue
        ), URLQueryItem(
                name: apiKey,
                value: key
        )]

        items.append(contentsOf: queryItems)

        items.append(URLQueryItem(
                name: "format",
                value: "json"
        ))

        items.append(URLQueryItem(
                name: "nojsoncallback",
                value: "1"
        ))

        return items
    }
}
