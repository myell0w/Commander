//
//  BaseCommand.swift
//  Commander
//
//  Created by Matthias Tretter on 20/04/2017.
//
//

import Foundation


/// a base (convenience) implementation of a Command
public class BaseCommand: Command {

    public lazy var command: Command = self.makeCommand()!
    public var state: State = .ready

    // MARK: - Command

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

    // MARK: - BaseCommand

    func makeCommand() -> Command? {
        // subclasses must implement
        return nil
    }
}
