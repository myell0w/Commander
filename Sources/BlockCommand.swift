//
//  BlockCommand.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


/// A command that can execute a block
public final class BlockCommand: Command {

    public typealias Block = (Void) -> Void

    private let executionBlock: Block
    private let inverseExecutionBlock: Block
    public let isAsynchronous: Bool
    public var state: State = .ready

    // MARK: - Lifecycle

    public init(command: @escaping Block, inverseCommand: @escaping Block, isAsynchronous: Bool = false) {
        self.executionBlock = command
        self.inverseExecutionBlock = inverseCommand
        self.isAsynchronous = isAsynchronous
    }

    // MARK: - Command

    public func invoke() {
        self.state = .executing
        self.executionBlock()
        // finish() must be called explicitly for asynchronous tasks
        if self.isAsynchronous == false {
            self.finish()
        }
    }

    public func inversed() -> Command {
        return BlockCommand(command: self.inverseExecutionBlock,
                            inverseCommand: self.executionBlock,
                            isAsynchronous: self.isAsynchronous)
    }
}
