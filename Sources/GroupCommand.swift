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

    public var timestamp: Date? {
        get {
            return self.commands.first?.timestamp
        }

        set {
            // do nothing
        }
    }

    public init(commands: [Command]) {
        self.commands = commands
    }

    public func invoke() {
        self.commands.forEach { $0.invoke() }
    }

    public func inversed() -> Command {
        let inversedCommands = self.commands.reversed().map { $0.inversed() }
        return GroupCommand(commands: inversedCommands)
    }
}
