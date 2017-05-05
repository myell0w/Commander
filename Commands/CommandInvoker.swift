//
//  CommandInvoker.swift
//  Commander
//
//  Created by Matthias Tretter on 05/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// CommandHandler that simply invokes a command
public final class CommandInvoker {

    // MARK: - Lifecycle

    public init() {
        // just to make accessible
    }
}

// MARK: - CommandHandler

extension CommandInvoker: CommandHandler {

    public func handleCommand(_ command: Command) {
        command.invoke()
    }
}
