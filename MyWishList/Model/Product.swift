//
//  Products.swift
//  MyWishList
//
//  Created by imhs on 4/15/24.
//

import Foundation

struct Product: Codable {
    var id: Int
    var title: String
    var description: String
    var price: Double
    var discountPercentage: Double
    var rating: Double
    var stock: Int
    var brand: String
    var category: String
    var thumbnail: String
    var images: [String]
}
