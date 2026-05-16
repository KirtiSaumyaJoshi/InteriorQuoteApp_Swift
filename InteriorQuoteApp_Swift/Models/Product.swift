//
//  Product.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 16/5/2026.
//

import Foundation

struct ProductApiResponse: Codable {
    let data: [Product]
}

struct Product: Codable {

    let id: String
    let type: String
    let title: String

    let description: String
    let imageUrl: String

    let pricePerSquareMeter: Double

    let minWidth: Double?
    let maxWidth: Double?

    let minHeight: Double?
    let maxHeight: Double?

    let maxPanelCount: Int?

    let variants: [String]
    var selectedVariant: String?

    enum CodingKeys: String, CodingKey {
        case id

        case type = "category"
        case title = "name"

        case description
        case imageUrl

        case pricePerSquareMeter = "price_per_sqm"

        case minWidth = "min_width"
        case maxWidth = "max_width"

        case minHeight = "min_height"
        case maxHeight = "max_height"

        case maxPanelCount = "max_panels"

        case variants
    }
}
