//
//  Property.swift
//  InteriorQuoteApp_Swift
//
//  Created by Kirti Saumya Joshi on 4/5/2026.
//

import Foundation

class Property {
    var id: String
    var propertyName: String

    var ownerFirstName: String
    var ownerMiddleName: String?
    var ownerLastName: String
    var ownerGender: String

    var addressLine: String
    var city: String
    var state: String
    var country: String
    var zipCode: String

    init(id: String = UUID().uuidString,
         propertyName: String,
         ownerFirstName: String,
         ownerMiddleName: String? = nil,
         ownerLastName: String,
         ownerGender: String,
         addressLine: String,
         city: String,
         state: String,
         country: String,
         zipCode: String) {

        self.id = id
        self.propertyName = propertyName
        self.ownerFirstName = ownerFirstName
        self.ownerMiddleName = ownerMiddleName
        self.ownerLastName = ownerLastName
        self.ownerGender = ownerGender
        self.addressLine = addressLine
        self.city = city
        self.state = state
        self.country = country
        self.zipCode = zipCode
    }

    var ownerFullName: String {
        if let middle = ownerMiddleName, !middle.isEmpty {
            return "\(ownerFirstName) \(middle) \(ownerLastName)"
        }
        return "\(ownerFirstName) \(ownerLastName)"
    }

    var fullAddress: String {
        return "\(addressLine), \(city), \(state), \(country) \(zipCode)"
    }
}
