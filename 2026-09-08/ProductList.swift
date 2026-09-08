//
//  ProductList.swift
//  SwiftUIDemo
//
//  Created by Shawn Defibaugh on 9/8/26.
//

import SwiftUI

struct ProductList: View {
    @State private var products: [Product] = []
    
    var body: some View {
        NavigationStack {
            List(products) { prod in
                NavigationLink(value: prod) {
                    HStack {
                        Text(prod.name).bold()
                        Spacer()
                        Text(prod.color)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .navigationTitle("Products")
            .navigationDestination(for: Product.self) {
                selectedItem in
                ProductDetails(product: selectedItem)
            }
        }
        .task {
            loadData()
        }
    }
    
    func loadData() {
        products = [
            Product(id: 887, name: "Ball", productNumber: "A-006", color: "Orange", listPrice: 5.99),
            Product(id: 889, name: "Figure", productNumber: "B-671", color: "Red", listPrice: 10.99),
            Product(id: 369, name: "Action Figure", productNumber: "Z-7291", color: "Black", listPrice: 24.99),
            Product(id: 732, name: "Cards", productNumber: "G-32671", color: "Red", listPrice: 2.99),
            Product(id: 327, name: "Frisbee", productNumber: "F-3728", color: "Yellow", listPrice: 11.99),
            Product(id: 274, name: "LEGO", productNumber: "B-1632", color: "Mixed", listPrice: 49.99),
            Product(id: 378, name: "Book", productNumber: "J-3726", color: "Brown", listPrice: 11.99),
            Product(id: 983, name: "Board Game", productNumber: "H-7281", color: "Mixed", listPrice: 20.99),
        ]
    }
}


#Preview {
    ProductList()
}

