//
//  Dictionary+Tuples.swift
//  Commander
//
//  Created by Matthias Tretter on 03/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
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
