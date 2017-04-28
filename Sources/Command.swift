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
    case canceled
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
        case .canceled:
            return 3
        case .forbidden:
            return 4
        }
    }

    public static func ==(lhs: State, rhs: State) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

/// The base interface for any executable command
public protocol Command: class, CustomStringConvertible {

    var timestamp: Date? { get }
    var state: State { get set }
    var isAsynchronous: Bool { get }
    var isMutating: Bool { get }

    func invoke()
    func inversed() -> Command

    func cancel()
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
        return "Command <\(type(of: self)) - state:\(self.state), async:\(self.isAsynchronous)>"
    }

    func cancel() {
        if case .finished(_) = self.state { return }
        if case .forbidden = self.state { return }

        self.state = .canceled
    }

    func finish() {
        guard case .executing = self.state else { return }

        self.state = .finished(timestamp: Date())
    }
}
