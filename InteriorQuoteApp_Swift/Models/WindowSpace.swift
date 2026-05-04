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
    var widthMM: Double
    var heightMM: Double
    
    // Product selection
    var productId: String?
    var productName: String?
    var pricePerSqm: Double?
    var selectedVariant: String?

    init(id: String = UUID().uuidString,
         name: String,
         widthMM: Double,
         heightMM: Double) {
        self.id = id
        self.name = name
        self.widthMM = widthMM
        self.heightMM = heightMM
    }

    func area() -> Double {
        return (widthMM / 1000.0) * (heightMM / 1000.0)
    }

    func cost() -> Double {
        return area() * (pricePerSqm ?? 50)
    }
}
