//
//  DataItemModel.swift
//  GalleryWithAPI
//
//  Created by LUNNOPARK on 16.02.23.
//

import Foundation

struct JSONDataModel: Codable {
    var data: [ItemModel]
    var itemsPerPage: Int?
    var countOfPages: Int?
    var totalItems: Int?
}

struct ItemModel: Codable {
    var id: Int?
    var name: String?
    var date: String?
    var new: Bool?
    var popular: Bool?
    var image: ImageModel
    
    enum CodingKeys: String, CodingKey {
        case id, name, new, popular, image
        case date = "dateCreate"
    }
}

struct ImageModel: Codable {
    var id: Int?
    var name: String?
}
