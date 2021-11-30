//
//  User+CoreDataProperties.swift
//  37JasferProject
//
//  Created by Jasfer Toh on 10/11/21.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var address: Data?
    @NSManaged public var cart: Data?
    @NSManaged public var credits: Double
    @NSManaged public var firstName: String?
    @NSManaged public var img: Data?
    @NSManaged public var isLoggedIn: Bool
    @NSManaged public var lastName: String?
    @NSManaged public var password: String?
    @NSManaged public var purchases: Data?
    @NSManaged public var username: String?
    @NSManaged public var topups: Data?

}

extension User : Identifiable {

}
