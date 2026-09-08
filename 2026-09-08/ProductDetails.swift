//
//  ProductDetails.swift
//  SwiftUIDemo
//
//  Created by Shawn Defibaugh on 9/8/26.
//

import SwiftUI

struct ProductDetails: View {
    
    var product: Product
    
    var body: some View {
        VStack {
            Text("ID: \(product.id)")
                .font(Font.largeTitle)
                .fontWeight(.bold)
            Text("Name: \(product.name)")
                .font(Font.title)
                .padding(5)
            Text("Product number: \(product.productNumber)")
                .font(Font.title)
                .padding(5)
            Text("Color: \(product.color)")
                .font(Font.title)
                .padding(5)
            Text("Price: \(product.listPrice, format: .currency(code: "USD"))")
                .font(Font.title)
                .padding(5)
        }
        .padding()
    }

}

#Preview {
    ProductDetails(
        product: Product(
            id: 1,
            name: "Ball",
            productNumber: "A-001",
            color: "Red",
            listPrice: 9.99
        )
    )
}
