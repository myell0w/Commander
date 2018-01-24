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

    private let commands: [Command]

    // MARK: - Lifecycle

    public init(commands: [Command]) {
        self.commands = commands
    }
}

// MARK: - Command

extension GroupCommand: Command {

    public var description: String {
        var commandsDescription = self.commands.reduce("") { $0 + "  " + $1.description + "\n" }
        let lastIndex = commandsDescription.index(before: commandsDescription.endIndex)
        commandsDescription = String(commandsDescription[..<lastIndex])

        return "<\(type(of: self))> {\n" + commandsDescription + "\n}"
    }

    public func invoke() {
        self.commands.forEach { $0.invoke() }
    }

    public func reverse() {
        self.commands.reversed().forEach { $0.reverse() }
    }
}
