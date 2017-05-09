//
//  CommandDispatcher.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


public protocol CommandDispatcherDelegate: class {

    func commandDispatcher(_ commandDispatcher: CommandDispatcher, willDispatchCommand command: Command)
    func commandDispatcher(_ commandDispatcher: CommandDispatcher, didDispatchCommand command: Command)
    func commandDispatcher(_ commandDispatcher: CommandDispatcher, didForbidCommand command: Command)
}


/// Controller class to invoke/dispatch commands
public final class CommandDispatcher {

    fileprivate let validator: CommandValidator?
    fileprivate var isInTransaction: Bool = false
    fileprivate var transactionStore: CommandStore = CommandStore()
    
    // MARK: - Properties

    public var handlers: [CommandHandler]
    public weak var delegate: CommandDispatcherDelegate?
    public private(set) var isDispatching: Bool = false

    // MARK: - Lifecycle

    public init(handlers: [CommandHandler] = [CommandInvoker()], validator: CommandValidator? = nil) {
        self.handlers = handlers
        self.validator = validator
    }

    // MARK: - CommandDispatcher

    public func canInvoke(_ command: Command) -> Bool {
        return self.validator?.validate(command: command) ?? true
    }

    public func invoke(_ command: Command) {
        guard self.isInTransaction == false else {
            self.transactionStore.handleCommand(command)
            return
        }

        guard command.state == .ready else {
            assertionFailure("Trying to invoke a Command that is not ready")
            return
        }

        guard self.canInvoke(command) else {
            command.state = .forbidden
            self.delegate?.commandDispatcher(self, didForbidCommand: command)
            return
        }

        self.isDispatching = true
        self.delegate?.commandDispatcher(self, willDispatchCommand: command)

        let handlers = self.handlers.filter { $0.isEnabled }
        handlers.forEach { $0.handleCommand(command) }

        self.delegate?.commandDispatcher(self, didDispatchCommand: command)
        self.isDispatching = false
    }

    public func withTransaction(_ work: () -> Void) {
        guard self.isInTransaction == false else {
            assertionFailure("Trying to group while already grouping")
            return
        }

        assert(self.transactionStore.commands.isEmpty)

        self.isInTransaction = true
        work()
        self.isInTransaction = false

        self.applyStore(self.transactionStore, grouped: true)
    }
}
