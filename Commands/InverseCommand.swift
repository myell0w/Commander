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

    // MARK: - Lifecycle

    public init(command: Command) {
        self.command = command
    }
}

// MARK: - Command

extension InverseCommand: Command {

    public func invoke() {
        self.command.reverse()
    }

    public func reverse() {
        self.command.invoke()
    }
}
