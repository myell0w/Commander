//
//  CommandDispatcher.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


public protocol CommandDispatcherDelegate: class {

    func commandDispatcher(_ commandDispatcher: CommandDispatcher, didInvokeCommand command: Command)
    func commandDispatcher(_ commandDispatcher: CommandDispatcher, didForbidCommand command: Command)
}


/// Controller class to invoke/dispatch commands
public final class CommandDispatcher {

    fileprivate let validator: CommandValidator?
    
    // MARK: - Properties

    public weak var delegate: CommandDispatcherDelegate?
    public var handlers: [CommandHandler]

    // MARK: - Lifecycle

    public init(validator: CommandValidator? = nil, handlers: [CommandHandler] = [CommandInvoker()]) {
        self.validator = validator
        self.handlers = handlers
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

        self.handlers.forEach { $0.handleCommand(command) }

        self.delegate?.commandDispatcher(self, didInvokeCommand: command)
    }
}
