//
//  FloorSpace.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 4/5/2026.
//

import Foundation

class FloorSpace {
    var id: String
    var name: String
    var widthMM: Double
    var depthMM: Double
    
    var productId: String?
    var productName: String?
    var pricePerSqm: Double?
    var selectedVariant: String?

    init(id: String = UUID().uuidString,
         name: String,
         widthMM: Double,
         depthMM: Double) {
        self.id = id
        self.name = name
        self.widthMM = widthMM
        self.depthMM = depthMM
    }

    func area() -> Double {
        return (widthMM / 1000.0) * (depthMM / 1000.0)
    }

    func cost() -> Double {
        return area() * (pricePerSqm ?? 100)
    }
}
