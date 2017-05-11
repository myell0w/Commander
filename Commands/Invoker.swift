//
//  CommandInvoker.swift
//  Commander
//
//  Created by Matthias Tretter on 05/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// An InvokeableHandler that simply invokes an invokeable object
public final class Invoker {

    // MARK: - Properties

    // (from InvokeableHandler) - Swift doesn't allow to move Properties to extensions (yet)
    public var isEnabled: Bool = true

    // MARK: - Lifecycle

    public init() {
        // just to make accessible
    }
}

// MARK: - InvokeableHandler

extension Invoker: InvokeableHandler {

    public func handleInvokeable(_ invokeable: Invokeable) {
        invokeable.invoke()
    }
}
