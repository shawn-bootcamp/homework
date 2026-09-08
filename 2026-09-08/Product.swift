//
//  Product.swift
//  SwiftUIDemo
//
//  Created by Shawn Defibaugh on 9/8/26.
//


//  1.  The Product class must contain the following properties:
//          - id is an Int
//          - name is a String
//          - productNumber is a String
//          - color is a String
//          - listPrice is a Double

import SwiftUI

@Observable

class Product: Identifiable, Hashable {
    var id: Int
    var name: String
    var productNumber: String
    var color: String
    var listPrice: Double
    
    init(id: Int, name: String, productNumber: String, color: String, listPrice: Double) {
        self.id = id
        self.name = name
        self.productNumber = productNumber
        self.color = color
        self.listPrice = listPrice
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
            lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
