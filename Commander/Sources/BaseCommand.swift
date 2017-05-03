//
//  BaseCommand.swift
//  Commander
//
//  Created by Matthias Tretter on 20/04/2017.
//
//

import Foundation


/// a base (convenience) implementation of a Command
public class BaseCommand {

    public lazy var command: Command = self.makeCommand()

    // (from Command) - Swift doesn't allow to move Properties to extensions (yet)
    public var state: State = .ready
    public var isAsynchronous: Bool {
        return false
    }

    public var isMutating: Bool {
        return true
    }

    // MARK: - BaseCommand

    func makeCommand() -> Command {
        fatalError("Subclasses must implement")
    }
}

// MARK: - Command

extension BaseCommand: Command {

    public func invoke() {
        self.state = .executing
        self.command.invoke()
        if self.isAsynchronous == false {
            self.finish()
        }
    }

    public func inversed() -> Command {
        return self.command.inversed()
    }
}
