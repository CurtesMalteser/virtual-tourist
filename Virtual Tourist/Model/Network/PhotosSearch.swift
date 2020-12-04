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
    let page, pages, perpage: Int
    let total: String
    let photo: [PhotoResponse]
}

struct PhotoResponse: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
}
