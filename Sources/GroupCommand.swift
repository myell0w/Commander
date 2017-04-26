//
//  GroupCommand.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


/// A command that groups other commands together
public final class GroupCommand: Command {

    private var commands: [Command]
    public var state: State {
        get {
            let states = self.commands.map { $0.state }
            let stateSet = Set(states)

            // no commands?
            guard stateSet.isEmpty == false else { return .ready }
            // all have same state
            guard stateSet.count > 1 else { return states[0] }

            // TODO: How to handle this correctly
            if stateSet.contains(.executing) {
                return .executing
            }

            return .ready
        }

        set {
            // do nothing
        }
    }

    public var isAsynchronous: Bool {
        return self.commands.lazy.filter({ $0.isAsynchronous }).isEmpty == false
    }

    public var isMutating: Bool {
        return self.commands.lazy.filter({ $0.isMutating }).isEmpty == false
    }

    // MARK: - Lifecycle

    public init(commands: [Command]) {
        self.commands = commands
    }

    // MARK: - Command

    public func invoke() {
        self.commands.forEach { $0.invoke() }
    }

    public func inversed() -> Command {
        let inversedCommands = self.commands.reversed().map { $0.inversed() }
        return GroupCommand(commands: inversedCommands)
    }

    public func cancel() {
        self.commands.forEach { $0.cancel() }
    }
}
