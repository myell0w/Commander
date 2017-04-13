//
//  Command.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


/// The base interface for any executable command
public protocol Command: class, CustomStringConvertible {

    var timestamp: Date? { get set }

    func invoke()
    func inversed() -> Command
}

extension Command {

    public var description: String {
        let executedDescription = self.timestamp != nil ? "executed at \(self.timestamp!)" : "not executed yet"
        return "Command <\(type(of: self)) \(executedDescription)>"
    }
}

public protocol WrapperCommand: Command {

    var command: Command { get }
}

extension WrapperCommand {

    public func invoke() {
        self.timestamp = Date()
        self.command.invoke()
    }

    public func inversed() -> Command {
        return self.command.inversed()
    }
}
