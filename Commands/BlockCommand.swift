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

    public typealias Block = () -> Void

    private let executionBlock: Block
    private let reverseExecutionBlock: Block

    // MARK: - Lifecycle

    public init(block: @escaping Block, reverseBlock: @escaping Block) {
        self.executionBlock = block
        self.reverseExecutionBlock = reverseBlock
    }
}

// MARK: - Command

extension BlockCommand: Command {

    public func invoke(context: InvocationContext? = nil) {
        self.executionBlock()
    }

    public func reverse(context: InvocationContext? = nil) {
        self.reverseExecutionBlock()
    }
}
