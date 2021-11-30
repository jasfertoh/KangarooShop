//
//  PurchaseHistory.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 5/11/21.
//

import Foundation

public class PurchaseHistory: NSObject, Codable {
    var productTitle: String
    var productPrice: Double
    var purchaseDate: Date
    
    init(title: String, price: Double, date: Date) {
        self.productTitle = title
        self.productPrice = price
        self.purchaseDate = date
    }
}
