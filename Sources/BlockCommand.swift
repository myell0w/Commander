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
    public var timestamp: Date?

    public init(command: @escaping Block, inverseCommand: @escaping Block) {
        self.executionBlock = command
        self.inverseExecutionBlock = inverseCommand
    }

    public func invoke() {
        self.timestamp = Date()
        self.executionBlock()
    }

    public func inversed() -> Command {
        return BlockCommand(command: self.inverseExecutionBlock, inverseCommand: self.executionBlock)
    }
}
