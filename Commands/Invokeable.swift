//
//  Invokeable.swift
//  Commander
//
//  Created by Matthias Tretter on 11/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// Invokeables can be invoked by a Dispatcher
public protocol Invokeable: AnyObject, CustomStringConvertible {

    func invoke()
}

// MARK: - CustomStringConvertible

public extension Invokeable {

    var description: String {
        let mirror = Mirror(reflecting: self)
        var fieldDescription = mirror.children.reduce("") { description, child in
            guard let label = child.label else { return description }

            let value = child.value is [Any] ? "[Array]" : child.value
            return description + "\(label): \(value), "
        }
        let lastIndex = fieldDescription.index(fieldDescription.endIndex, offsetBy: -2)
        fieldDescription = String(fieldDescription[..<lastIndex])

        return "<\(type(of: self))> { \(fieldDescription) }"
    }
}
