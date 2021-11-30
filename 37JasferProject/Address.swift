//
//  Address.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 5/11/21.
//

import Foundation

public class Address: NSObject, Codable {
    var address: String
    var main: Bool
    var addressList: [String: Bool]
    
    init(add: String, mainAddress: Bool) {
        self.address = add
        self.main = mainAddress
        self.addressList = [address: main]
    }
}
