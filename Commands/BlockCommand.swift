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
    fileprivate let reverseExecutionBlock: Block

    // (from Invokeable) - Swift doesn't allow to move Properties to extensions (yet)
    public var state: State = .ready
    public var uuid: Identifier

    // MARK: - Lifecycle

    public init(uuid: Identifier = UUID(), block: @escaping Block, reverseBlock: @escaping Block) {
        self.uuid = uuid
        self.executionBlock = block
        self.reverseExecutionBlock = reverseBlock
    }
}

// MARK: - Command

extension BlockCommand: Command {

    public func invoke() {
        self.state = .executing
        self.executionBlock()
        self.finish()
    }

    public func reverse() {
        self.state = .executing
        self.reverseExecutionBlock()
        self.state = .ready
    }
}
