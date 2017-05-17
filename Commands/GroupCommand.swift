//
//  GroupCommand.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


/// A command that groups other commands
public final class GroupCommand {

    fileprivate let commands: [Command]

    // (from Invokeable) - Swift doesn't allow to move Properties to extensions (yet)
    public var uuid: Identifier

    // MARK: - Lifecycle

    public init(uuid: Identifier = UUID(), commands: [Command]) {
        self.uuid = uuid
        self.commands = commands
    }
}

// MARK: - Command

extension GroupCommand: Command {

    public var state: State {
        get {
            let states = self.commands.map { $0.state }
            let stateSet = Set(states)

            // no commands?
            guard stateSet.isEmpty == false else { return .ready }
            // all have same state
            guard stateSet.count > 1 else { return states[0] }

            // TODO: How to handle this correctly?
            if stateSet.contains(.executing) {
                return .executing
            } else if stateSet.contains(.forbidden) {
                return .forbidden
            }

            return .ready
        }

        set {
            // do nothing
        }
    }

    public var description: String {
        var commandsDescription = self.commands.reduce("") { $0 + "  " + $1.description + "\n" }
        let lastIndex = commandsDescription.index(before: commandsDescription.endIndex)
        commandsDescription = commandsDescription.substring(to: lastIndex)

        return "<\(type(of: self)) state:\(self.state)> {\n" + commandsDescription + "\n}"
    }

    public func invoke() {
        self.commands.forEach { $0.invoke() }
    }

    public func reverse() {
        self.commands.reversed().forEach { $0.reverse() }
    }
}
