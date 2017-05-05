//
//  CommandLogger.swift
//  Commander
//
//  Created by Matthias Tretter on 05/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// CommandHandler that logs commands to a TextOutputStream
public final class CommandLogger {

    fileprivate let outputStreamPointer: UnsafeMutablePointer<TextOutputStream>?

    // MARK: - Lifecycle

    public init(outputStream: UnsafeMutablePointer<TextOutputStream>? = nil) {
        self.outputStreamPointer = outputStream
    }
}

// MARK: - CommandHandler

extension CommandLogger: CommandHandler {

    public func handleCommand(_ command: Command) {
        let description = command.description

        if let outputStream = self.outputStreamPointer {
            outputStream.pointee.write(description + "\n")
        } else {
            print(description)
        }
    }
}
