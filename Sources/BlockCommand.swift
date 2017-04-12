//
//  BlockCommand.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


/// A command that can execute a block
public struct BlockCommand: Command {

    public typealias Block = (Void) -> Void

    private let command: Block
    private let inverseCommand: Block

    public init(command: @escaping Block, inverseCommand: @escaping Block) {
        self.command = command
        self.inverseCommand = inverseCommand
    }

    public func invoke() {
        self.command()
    }

    public func inversed() -> Command {
        return BlockCommand(command: self.inverseCommand, inverseCommand: self.command)
    }
}
