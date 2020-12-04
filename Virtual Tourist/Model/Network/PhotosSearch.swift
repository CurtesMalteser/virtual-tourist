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

// MARK: PhotoSizeResponse
// Used to parse the JSON response for each PhotoResponse id
struct PhotoSizeResponse: Codable {
    let sizes: Sizes
    let stat: String
}

// MARK: - Sizes
struct Sizes: Codable {
    let canBlog, canPrint, canDownload: Int
    let photoSize: [PhotoSize]

    enum CodingKeys: String, CodingKey {
        case canBlog = "canblog"
        case canPrint = "canprint"
        case canDownload = "candownload"
        case photoSize = "size"
    }
}

// MARK: - PhotoSize
struct PhotoSize: Codable {
    let label: String
    let width, height: Int
    let source: String
    let url: String
    let media: Media
}

enum Media: String, Codable {
    case photo = "photo"
}
