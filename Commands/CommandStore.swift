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

    public static func makeScratchpad(_ work: (CommandDispatcher) -> Void) -> CommandStore {
        let store = CommandStore()
        let commandDispatcher = CommandDispatcher(handlers: [store])
        work(commandDispatcher)
        return store
    }

    public func applyStore(_ store: CommandStore, grouped: Bool = false) {
        if grouped {
            let groupCommand = GroupCommand(commands: store.commands)
            self.invoke(groupCommand)
        } else {
            for command in store.commands {
                self.invoke(command)
            }
        }

        store.reset()
    }
}
