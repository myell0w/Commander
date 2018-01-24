//
//  CommandLogger.swift
//  Commander
//
//  Created by Matthias Tretter on 05/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// InvokeableHandler that logs commands to a TextOutputStream
public final class InvokeableLogger {

    private let outputStreamPointer: UnsafeMutablePointer<TextOutputStream>?

    // MARK: - Properties

    // (from InvokeableHandler) - Swift doesn't allow to move Properties to extensions (yet)
    public var isEnabled: Bool = true

    // MARK: - Lifecycle

    public init(outputStream: UnsafeMutablePointer<TextOutputStream>? = nil) {
        self.outputStreamPointer = outputStream
    }
}

// MARK: - InvokeableHandler

extension InvokeableLogger: InvokeableHandler {

    public func handleInvokeable(_ invokeable: Invokeable) {
        let description = invokeable.description

        if let outputStream = self.outputStreamPointer {
            outputStream.pointee.write(description + "\n")
        } else {
            print(description)
        }
    }
}
