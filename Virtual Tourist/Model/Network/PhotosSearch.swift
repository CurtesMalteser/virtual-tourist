//
//  PhotosSearch.swift
//  Virtual Tourist
//
//  Created by António Bastião on 04.12.20.
//

import Foundation

struct PhotosSearch: Codable {
    let photos: Photos
}

struct Photos: Codable {
    let page, pages, perPage: Int
    let total: String?
    let photoListResponse: [PhotoResponse]?

    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perPage = "perpage"
        case total = "total"
        case photoListResponse = "photo"
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
    let sizes: Sizes?
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
    let size: PhotoSizeEnum
    let width, height: Int
    let photoURL: String
    let media: Media

    enum CodingKeys: String, CodingKey {
        case size = "label"
        case width = "width"
        case height = "height"
        case photoURL = "source"
        case media = "media"
    }
}

enum Media: String, Codable {
    case photo = "photo"
}

enum PhotoSizeEnum: String, Codable {
    case square = "Square"
    case largeSquare = "Large Square"
    case thumbnail = "Thumbnail"
    case small = "Small"
    case small320 = "Small 320"
    case small400 = "Small 400"
    case medium = "Medium"
    case medium640 = "Medium 640"
    case medium800 = "Medium 800"
    case large = "Large"
    case large1600 = "Large 1600"
    case large2048 = "Large 2048"
    case xLarge3K = "X-Large 3K"
    case xLarge4K = "X-Large 4K"
    case xLarge5K = "X-Large 5K"
    case xLarge6K = "X-Large 6K"
    case original = "Original"
}