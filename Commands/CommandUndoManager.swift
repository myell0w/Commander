//
//  CommandUndoHandler.swift
//  Commander
//
//  Created by Matthias Tretter on 03/05/2017.
//
//

import Foundation

public protocol CommandUndoManagerDelegate: class {

    func commandUndoManager(_ undoManager: CommandUndoManager, didUndoCommand command: Command)
    func commandUndoManager(_ undoManager: CommandUndoManager, didRedoCommand command: Command)
}


public final class CommandUndoManager {

    public enum Error: Swift.Error {
        case undo
        case redo
    }

    fileprivate(set) var commands: [Command] = []
    fileprivate(set) var undoneCommands: [Command] = []

    // MARK: - Properties

    public weak var delegate: CommandUndoManagerDelegate?

    // MARK: - Lifecycle

    public init() {
        // just to make accessible
    }

    // MARK: - CommandUndoManager

    public func canUndo(numberOfCommands: Int = 1) -> Bool {
        return self.commands.count >= numberOfCommands
    }

    public func undo(numberOfCommands: Int = 1) throws {
        guard self.canUndo(numberOfCommands: numberOfCommands) else { throw Error.undo }

        let commandsToUndo = self.commands.remove(last: numberOfCommands).reversed()
        commandsToUndo.forEach { command in
            command.inverse()
            self.undoneCommands.append(command)
            self.delegate?.commandUndoManager(self, didUndoCommand: command)
        }
    }

    public func canRedo(numberOfCommands: Int = 1) -> Bool {
        return self.undoneCommands.count >= numberOfCommands
    }

    public func redo(numberOfCommands: Int = 1) throws {
        guard self.canRedo(numberOfCommands: numberOfCommands) else { throw Error.redo }

        let commandsToRedo = self.undoneCommands.remove(last: numberOfCommands).reversed()
        commandsToRedo.forEach { command in
            command.invoke()
            self.commands.append(command)
            self.delegate?.commandUndoManager(self, didRedoCommand: command)
        }
    }

    public func reset() {
        self.commands.removeAll()
        self.undoneCommands.removeAll()
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

    mutating func remove(last elementCount: Int) -> ArraySlice<Element> {
        let slices = (self.dropLast(elementCount), self.suffix(elementCount))

        self = Array(slices.0)
        return slices.1
    }
}
