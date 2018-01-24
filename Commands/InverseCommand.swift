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

    private let command: Command

    // (from Invokeable) - Swift doesn't allow to move Properties to extensions (yet)
    public var state: State = .ready
    public var uuid: Identifier

    // MARK: - Lifecycle

    public init(uuid: Identifier = UUID(), command: Command) {
        self.uuid = uuid
        self.command = command
    }
}

// MARK: - Command

extension InverseCommand: Command {

    public func invoke() {
        self.state = .executing
        self.command.reverse()
        self.finish()
    }

    public func reverse() {
        self.state = .executing
        self.command.invoke()
        self.state = .ready
    }
}
