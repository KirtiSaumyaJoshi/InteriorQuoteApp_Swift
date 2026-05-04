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
    
    var windows: [WindowSpace]
    var floors: [FloorSpace]

    init(id: String = UUID().uuidString,
         name: String,
         imageUrl: String? = nil,
         windows: [WindowSpace] = [],
         floors: [FloorSpace] = []) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.windows = windows
        self.floors = floors
    }
}
