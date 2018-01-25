//
//  CommandDispatcher.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


public protocol DispatcherDelegate: AnyObject {

    func dispatcher(_ dispatcher: Dispatcher, willDispatchInvokeable invokeable: Invokeable)
    func dispatcher(_ dispatcher: Dispatcher, didDispatchInvokeable invokeable: Invokeable)
    func dispatcher(_ dispatcher: Dispatcher, didForbidInvokeable invokeable: Invokeable)
}

public protocol InvocationContextProvider: AnyObject {

    func invocationContext(for invokable: Invokeable) -> InvocationContext?
}


/// Controller class to invoke/dispatch commands
public final class Dispatcher {

    private let validator: Validator?
    private var isInTransaction: Bool = false
    private var transactionStore: CommandStore = CommandStore()
    
    // MARK: - Properties

    public var handlers: [InvokeableHandler]
    public weak var delegate: DispatcherDelegate?
    public weak var invocationContextProvider: InvocationContextProvider?
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
        assert(Thread.isMainThread, "`invoke` must be called on the main thread")

        let invocationContext = self.invocationContextProvider?.invocationContext(for: invokeable)

        guard self.isInTransaction == false else {
            assert(invokeable is Command, "Transactions are only supported for Commands")
            self.transactionStore.handleInvokeable(invokeable, context: invocationContext)
            return
        }

        guard self.canInvoke(invokeable) else {
            self.delegate?.dispatcher(self, didForbidInvokeable: invokeable)
            return
        }

        self.isDispatching = true
        self.delegate?.dispatcher(self, willDispatchInvokeable: invokeable)

        let handlers = self.handlers.filter { $0.isEnabled }
        handlers.forEach { $0.handleInvokeable(invokeable, context: invocationContext) }

        self.delegate?.dispatcher(self, didDispatchInvokeable: invokeable)
        self.isDispatching = false
    }
}

// MARK: - Convenience Methods

extension Dispatcher {

    public func withTransaction(_ work: () -> Void) {
        assert(Thread.isMainThread, "`withTransaction` must be called on the main thread")

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
}
