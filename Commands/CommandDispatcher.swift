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
        guard self.canInvoke(command) else {
            command.state = .forbidden
            self.delegate?.commandDispatcher(self, didForbidCommand: command)
            return
        }

        self.isDispatching = true
        self.delegate?.commandDispatcher(self, willDispatchCommand: command)

        self.handlers.forEach { $0.handleCommand(command) }

        self.delegate?.commandDispatcher(self, didDispatchCommand: command)
        self.isDispatching = false
    }
}
