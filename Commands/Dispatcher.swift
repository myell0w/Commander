//
//  CommandDispatcher.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


public protocol DispatcherDelegate: class {

    func dispatcher(_ dispatcher: Dispatcher, willDispatchInvokeable invokeable: Invokeable)
    func dispatcher(_ dispatcher: Dispatcher, didDispatchInvokeable invokeable: Invokeable)
    func dispatcher(_ dispatcher: Dispatcher, didForbidInvokeable invokeable: Invokeable)
}


/// Controller class to invoke/dispatch commands
public final class Dispatcher {

    fileprivate let validator: Validator?
    fileprivate var isInTransaction: Bool = false
    fileprivate var transactionStore: CommandStore = CommandStore()
    
    // MARK: - Properties

    public var handlers: [InvokeableHandler]
    public weak var delegate: DispatcherDelegate?
    public private(set) var isDispatching: Bool = false

    // MARK: - Lifecycle

    public init(handlers: [InvokeableHandler] = [Invoker()], validator: Validator? = nil) {
        self.handlers = handlers
        self.validator = validator
    }

    // MARK: - CommandDispatcher

    public func canInvoke(_ invokeable: Invokeable) -> Bool {
        return self.validator?.validate(invokeable: invokeable) ?? true
    }

    public func invoke(_ invokeable: Invokeable) {
        guard self.isInTransaction == false else {
            assert(invokeable is Command, "Transactions are only supported for Commands")
            self.transactionStore.handleInvokeable(invokeable)
            return
        }

        guard invokeable.state == .ready else {
            assertionFailure("Trying to invoke a Command that is not ready")
            return
        }

        guard self.canInvoke(invokeable) else {
            invokeable.state = .forbidden
            self.delegate?.dispatcher(self, didForbidInvokeable: invokeable)
            return
        }

        self.isDispatching = true
        self.delegate?.dispatcher(self, willDispatchInvokeable: invokeable)

        let handlers = self.handlers.filter { $0.isEnabled }
        handlers.forEach { $0.handleInvokeable(invokeable) }

        self.delegate?.dispatcher(self, didDispatchInvokeable: invokeable)
        self.isDispatching = false
    }
}

// MARK: - Convenience Methods

extension Dispatcher {

    public func withTransaction(_ work: () -> Void) {
        guard self.isInTransaction == false else {
            assertionFailure("Trying to group while already grouping")
            return
        }

        assert(self.transactionStore.commands.isEmpty)

        self.isInTransaction = true
        work()
        self.isInTransaction = false

        self.applyStore(self.transactionStore, asTransaction: true)
    }

    public func withDisabledHandler(_ handler: InvokeableHandler, work: () -> Void) {
        self.withDisabledHandlers([handler], work: work)
    }

    public func withDisabledHandlers(_ handlers: [InvokeableHandler], work: () -> Void) {
        let enabledSnapshot: [(handler: InvokeableHandler, isEnabled: Bool)] = handlers.map { ($0, $0.isEnabled) }
        defer {
            enabledSnapshot.forEach { $0.handler.isEnabled = $0.isEnabled }
        }

        handlers.forEach { $0.isEnabled = false }
        self.withTransaction(work)
    }

    public func invokeProduced(_ producer: @autoclosure @escaping (Void) -> Command) {
        self.invoke(ProduceCommand(producer: producer))
    }
}
