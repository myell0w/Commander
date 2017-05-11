//
//  BlockCommand.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


/// A command that can execute a block
public final class BlockCommand {

    public typealias Block = (Void) -> Void

    fileprivate let executionBlock: Block
    fileprivate let inverseExecutionBlock: Block

    // (from Invokeable) - Swift doesn't allow to move Properties to extensions (yet)
    public var state: State = .ready

    // MARK: - Lifecycle

    public init(block: @escaping Block, inverseBlock: @escaping Block) {
        self.executionBlock = block
        self.inverseExecutionBlock = inverseBlock
    }
}

// MARK: - Command

extension BlockCommand: Command {

    public func invoke() {
        self.state = .executing
        self.executionBlock()
        self.finish()
    }

    public func inverse() {
        self.state = .executing
        self.inverseExecutionBlock()
        self.state = .ready
    }
}
