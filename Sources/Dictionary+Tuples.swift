//
//  Dictionary+Tuples.swift
//  Commander
//
//  Created by Matthias Tretter on 13/04/2017.
//
//

import Foundation


extension Dictionary {

    init(tuples: [(Key, Value)]) {
        var dictionary: [Key: Value] = [:]
        for (key, value) in tuples {
            dictionary[key] = value
        }

        self = dictionary
    }
}
