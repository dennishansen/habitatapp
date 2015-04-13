//
//  Habit.swift
//  Habitat
//
//  Created by Brian Palma on 4/12/15.
//  Copyright (c) 2015 Eastman Labs, LLC. All rights reserved.
//

import UIKit

class Habit: NSObject {
    
    var name: String
    
    // MARK: - Initialization
    
    override init() {
        name = "New Habit"
        super.init()
    }
    
    convenience init(dictionary: [String:String]) {
        self.init()
        name = dictionary["name"] ?? "New Habit"
    }
    
    // MARK: - NSCoding
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        name = aDecoder.decodeObjectForKey("name") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
    }
}
