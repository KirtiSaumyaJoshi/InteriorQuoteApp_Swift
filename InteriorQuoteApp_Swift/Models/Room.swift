//
//  Room.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 4/5/2026.
//

import Foundation
 
class Room {
    var id: String
    var name: String
    var imageUrl: String?
    var isComplete: Bool
    var windows: [WindowSpace]
    var floors: [FloorSpace]
    var windowCount: Int
    var hasFloor: Bool
    var isFloorIncludedInQuote: Bool
 
    init(id: String = UUID().uuidString,
         name: String,
         imageUrl: String? = nil,
         windows: [WindowSpace] = [],
         floors: [FloorSpace] = [],
         isComplete: Bool = false,
         windowCount: Int = 0,
         hasFloor: Bool = false,
         isFloorIncludedInQuote: Bool = true) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.windows = windows
        self.floors = floors
        self.isComplete = isComplete
        self.windowCount = windowCount
        self.hasFloor = hasFloor
        self.isFloorIncludedInQuote = isFloorIncludedInQuote
    }
    func quoteCost() -> Double {
        let windowTotal = windows
            .filter { $0.isIncludedInQuote }
            .reduce(0.0) { $0 + $1.cost() }

        let floorTotal: Double
        if isFloorIncludedInQuote, let floor = floors.first {
            floorTotal = floor.cost()
        } else {
            floorTotal = 0
        }

        return windowTotal + floorTotal
    }
}
 
