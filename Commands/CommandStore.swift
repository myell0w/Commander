//
//  CommandStore.swift
//  Commander
//
//  Created by Matthias Tretter on 09/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// A CommandHandler that simply stores a reference to all handled Commands
public final class CommandStore {

    // MARK: - Properties

    public fileprivate(set) var commands: [Command] = []
    // (from CommandHandler) - Swift doesn't allow to move Properties to extensions (yet)
    public var isEnabled: Bool = true

    // MARK: - Lifecycle

    public init() {
        // just to make accessible
    }

    // MARK: - CommandStore

    public func reset() {
        self.commands = []
    }
}

// MARK: - CommandHandler

extension CommandStore: CommandHandler {

    public func handleCommand(_ command: Command) {
        self.commands.append(command)
    }
}

// MARK: - CommandDispatcher

extension CommandDispatcher {

    public func applyStore(_ store: CommandStore, asTransaction: Bool = false) {
        if asTransaction {
            let groupCommand = GroupCommand(commands: store.commands)
            self.invoke(groupCommand)
        } else {
            store.commands.forEach { self.invoke($0) }
        }

        store.reset()
    }
}
