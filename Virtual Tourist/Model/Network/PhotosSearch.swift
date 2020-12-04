//
//  PhotosSearch.swift
//  Virtual Tourist
//
//  Created by António Bastião on 04.12.20.
//

import Foundation

struct PhotosSearch: Codable {
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page, pages, perPage: Int
    let total: String
    let photo: [PhotoResponse]

    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perPage = "perpage"
        case total = "total"
        case photo = "photo"
    }

}

struct PhotoResponse: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
}
