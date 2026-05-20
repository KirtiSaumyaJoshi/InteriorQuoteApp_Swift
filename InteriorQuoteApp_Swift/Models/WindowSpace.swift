//
//  WindowSpace.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 4/5/2026.
//

import Foundation

class WindowSpace {
    var id: String
    var name: String
    var widthMM: Double?
    var heightMM: Double?
    var imageUrl: String?
    var isIncludedInQuote: Bool
    var productId: String?
    var productName: String?
    var pricePerSqm: Double?
    var selectedVariant: String?

    init(id: String = UUID().uuidString,
         name: String,
         widthMM: Double? = nil,
         heightMM: Double? = nil,
         imageUrl: String? = nil,
         productId: String? = nil,
         productName: String? = nil,
         pricePerSqm: Double? = nil,
         isIncludedInQuote: Bool = true,
         selectedVariant: String? = nil) {

        self.id = id
        self.name = name
        self.widthMM = widthMM
        self.heightMM = heightMM
        self.imageUrl = imageUrl
        self.productId = productId
        self.productName = productName
        self.pricePerSqm = pricePerSqm
        self.selectedVariant = selectedVariant
        self.isIncludedInQuote = isIncludedInQuote
    }

    func area() -> Double {
        guard let widthMM = widthMM,
              let heightMM = heightMM else {
            return 0
        }

        return (widthMM / 1000.0) * (heightMM / 1000.0)
    }

    func cost() -> Double {
        return area() * (pricePerSqm ?? 50)
    }
}
