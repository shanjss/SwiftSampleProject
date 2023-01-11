//
//  Gallery.swift
//  SearchImage
//
//  Created by Shantanu Barnawal on 10/1/2021.
//

import Foundation

struct GalleryResponse: Codable {
  let data: [Gallery]
}

struct Gallery: Codable {
    let id: String
    var images: [ImageEntity]?
    let link: String
    let title: String
}

struct ImageEntity: Codable {
    let height: Int
    let id: String
    let link: String
    var title: String?
    let width: Int
}

class Utility {
    static func getImageList(_ galleries:[Gallery]) -> [ImageEntity] {
        var imageEntities = [ImageEntity] ()
        galleries.forEach { gallery in
            if let images = gallery.images, !images.isEmpty {
                images.forEach { image in
                    if image.link.hasSuffix("jpg") || image.link.hasSuffix("png") {
                        imageEntities.append(image)
                    }
                }
            }
        }
        return imageEntities
    }
}
