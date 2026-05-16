//
//  FloorSpace.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 4/5/2026.
//

import Foundation

class FloorSpace {
    var id: String
    var widthMM: Double
    var depthMM: Double

    var productId: String?
    var productName: String?
    var pricePerSqm: Double?

    init(id: String = UUID().uuidString,
         widthMM: Double,
         depthMM: Double,
         productId: String? = nil,
         productName: String? = nil,
         pricePerSqm: Double? = nil) {
        self.id = id
        self.widthMM = widthMM
        self.depthMM = depthMM
        self.productId = productId
        self.productName = productName
        self.pricePerSqm = pricePerSqm
    }

    func area() -> Double {
        return (widthMM / 1000.0) * (depthMM / 1000.0)
    }

    func cost() -> Double {
        return area() * (pricePerSqm ?? 100)
    }
}
