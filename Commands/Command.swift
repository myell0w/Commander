//
//  Command.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


/// A Command is an Invokable that mutates state and needs to be reversible
public protocol Command: Invokeable {

    func reverse()
}


/// Convenience Base Implementation of the Command Protocol
open class BaseCommand {

    lazy var command: Command = self.makeCommand()

    // (from Invokeable) - Swift doesn't allow to move Properties to extensions (yet)
    public var state: State = .ready

    // MARK: - Lifecycle

    public init() {
        // just to make available
    }

    // MARK: - BaseCommand

    open func makeCommand() -> Command {
        fatalError("Subclasses must implement")
    }
}

// MARK: - Command

extension BaseCommand: Command {

    public func invoke() {
        self.state = .executing
        self.command.invoke()
        self.finish()
    }

    public func reverse() {
        self.state = .executing
        self.command.reverse()
        self.state = .ready
    }
}
