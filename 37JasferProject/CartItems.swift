//
//  CartItems.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 5/11/21.
//

import Foundation

public class CartItems: NSObject, Codable {
    var productTitle: String
    var productImage: String
    var productPrice: Double
    var productDescription: String
    
    init(title: String, image: String, price: Double, description: String) {
        self.productTitle = title
        self.productImage = image
        self.productPrice = price
        self.productDescription = description
    }
}
