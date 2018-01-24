//
//  CommandStore.swift
//  Commander
//
//  Created by Matthias Tretter on 09/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// A InvokeableHandler that simply stores a reference to all handled Commands
public final class CommandStore {

    // MARK: - Properties

    public private(set) var commands: [Command] = []
    // (from InvokeableHandler) - Swift doesn't allow to move Properties to extensions (yet)
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

// MARK: - InvokeableHandler

extension CommandStore: InvokeableHandler {

    public func handleInvokeable(_ invokeable: Invokeable) {
        guard let command = invokeable as? Command else { return }

        self.commands.append(command)
    }
}

// MARK: - Dispatcher

extension Dispatcher {

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
