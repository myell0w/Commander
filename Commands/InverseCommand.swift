//
//  InverseCommand.swift
//  Commander
//
//  Created by Matthias Tretter on 07/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// A command that inverses another command

public final class InverseCommand {

    fileprivate let command: Command

    // (from Command) - Swift doesn't allow to move Properties to extensions (yet)
    public var state: State = .ready
    public var isMutating: Bool { return self.command.isMutating }

    // MARK: - Lifecycle

    public init(command: Command) {
        self.command = command
    }
}

// MARK: - Command

extension InverseCommand: Command {

    public func invoke() {
        self.state = .executing
        self.command.inverse()
        self.finish()
    }

    public func inverse() {
        self.state = .executing
        self.command.invoke()
        self.state = .ready
    }
}
