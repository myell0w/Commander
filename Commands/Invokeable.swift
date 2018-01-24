//
//  Invokeable.swift
//  Commander
//
//  Created by Matthias Tretter on 11/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// The state an invokeable can be in
public enum State {

    case ready
    case executing
    case finished(timestamp: Date)
    case forbidden
}

extension State: Hashable, Equatable {

    public var hashValue: Int {
        switch self {
        case .ready:
            return 0
        case .executing:
            return 1
        case .finished(timestamp: _):
            return 2
        case .forbidden:
            return 3
        }
    }

    public static func ==(lhs: State, rhs: State) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}


/// Invokeables can be invoked by a Dispatcher and can be either Querys or Commands
public protocol Invokeable: class, CustomStringConvertible {

    typealias Identifier = UUID

    var uuid: Identifier { get }
    var state: State { get set }
    var timestamp: Date? { get }

    func invoke()
    func finish()
}

public extension Invokeable {

    var timestamp: Date? {
        if case let .finished(timestamp) = self.state {
            return timestamp
        }

        return nil
    }

    var description: String {
        let mirror = Mirror(reflecting: self)
        var fieldDescription = mirror.children.reduce("") { description, child in
            guard let label = child.label else { return description }

            let value = child.value is [Any] ? "[Array]" : child.value
            return description + "\(label): \(value), "
        }
        let lastIndex = fieldDescription.index(fieldDescription.endIndex, offsetBy: -2)
        fieldDescription = String(fieldDescription[..<lastIndex])

        return "<\(type(of: self)) state: \(self.state)> { \(fieldDescription) }"
    }

    func finish() {
        guard case .executing = self.state else {
            assertionFailure("finish() was called on a Command that's not executing")
            return
        }

        self.state = .finished(timestamp: Date())
    }
}
