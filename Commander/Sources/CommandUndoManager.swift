//
//  CommandUndoHandler.swift
//  Commander
//
//  Created by Matthias Tretter on 03/05/2017.
//
//

import Foundation


public final class CommandUndoManager {

    public enum Error: Swift.Error {
        case undo
        case redo
    }

    fileprivate(set) var commands: [Command] = []
    fileprivate(set) var undoneCommands: [Command] = []

    // MARK: - CommandUndoManager

    public func undo(numberOfCommands: Int = 1) throws {
        guard self.commands.count >= numberOfCommands else { throw Error.undo }

        let commandsToUndo = self.commands.remove(last: numberOfCommands).reversed()
        commandsToUndo.forEach { command in
            command.cancel()
            command.inversed().invoke()
            self.undoneCommands.append(command)
        }
    }

    public func redo(numberOfCommands: Int = 1) throws {
        guard self.undoneCommands.count >= numberOfCommands else { throw Error.redo }

        let commandsToRedo = self.undoneCommands.remove(first: numberOfCommands)
        commandsToRedo.forEach { command in
            command.invoke()
            self.commands.append(command)
        }
    }
}

// MARK: - CommandHandler

extension CommandUndoManager: CommandHandler {

    public func handleCommand(_ command: Command) {
        self.commands.append(command)
        self.undoneCommands.removeAll()
    }
}

// MARK: - Private

private extension Array {

    mutating func remove(first elementCount: Int) -> ArraySlice<Element> {
        let slices = (self.dropFirst(elementCount), self.prefix(elementCount))

        self = Array(slices.0)
        return slices.1
    }

    mutating func remove(last elementCount: Int) -> ArraySlice<Element> {
        let slices = (self.dropLast(elementCount), self.suffix(elementCount))

        self = Array(slices.0)
        return slices.1
    }
}
