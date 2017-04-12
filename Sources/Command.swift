//
//  Command.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


/// The base interface for any executable command
public protocol Command: CustomStringConvertible {

    func invoke()
    func inversed() -> Command
}

extension Command {

    public var description: String {
        return "Command <\(type(of: self))>"
    }
}

public protocol WrapperCommand: Command {
    var command: Command { get }
}

extension WrapperCommand {

    public func invoke() {
        self.command.invoke()
    }

    public func inversed() -> Command {
        return self.command.inversed()
    }
}
