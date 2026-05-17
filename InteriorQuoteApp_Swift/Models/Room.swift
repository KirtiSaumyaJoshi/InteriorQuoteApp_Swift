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
    
    init(id: String = UUID().uuidString,
         name: String,
         imageUrl: String? = nil,
         windows: [WindowSpace] = [],
         floors: [FloorSpace] = [],
         isComplete: Bool = false,
         windowCount: Int = 0,
         hasFloor: Bool = false) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.windows = windows
        self.floors = floors
        self.isComplete = isComplete
        self.windowCount = windowCount
        self.hasFloor = hasFloor
    }
}
