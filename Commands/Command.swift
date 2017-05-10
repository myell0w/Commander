//
//  Command.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


// MARK: - Command

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

/// The base interface for any executable command
public protocol Command: class, CustomStringConvertible {

    // TODO: var uuid: UUID
    var state: State { get set }
    var timestamp: Date? { get }
    var isMutating: Bool { get } // CQS

    func invoke()
    func inverse()
    func finish()
}

public extension Command {

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
        fieldDescription = fieldDescription.substring(to: lastIndex)

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
