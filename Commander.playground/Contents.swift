//: Playground - noun: a place where people can play

import UIKit

/// Simple playground to test an API that we can use for operation-based actions
/// to modify objects.
///
/// TODO:
/// - [ ] Asynchronous Commands (Futures?)
/// - [ ] Cancelable Commands (Result<T>?)


// MARK: - Base Commands

protocol Command: CustomStringConvertible {

    func invoke()
    func inversed() -> Command
}

extension Command {

    var description: String {
        return "Command of type '\(type(of: self))'"
    }
}

extension Array {

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


struct BlockCommand: Command {

    typealias Block = (Void) -> Void

    private let command: Block
    private let inverseCommand: Block

    init(command: @escaping Block, inverseCommand: @escaping Block) {
        self.command = command
        self.inverseCommand = inverseCommand
    }

    func invoke() {
        self.command()
    }

    func inversed() -> Command {
        return BlockCommand(command: self.inverseCommand, inverseCommand: self.command)
    }
}


struct GroupCommand: Command {

    private let commands: [Command]

    init(commands: [Command]) {
        self.commands = commands
    }

    func invoke() {
        self.commands.forEach { $0.invoke() }
    }

    func inversed() -> Command {
        let inversedCommands = self.commands.reversed().map { $0.inversed() }
        return GroupCommand(commands: inversedCommands)
    }
}

// MARK: - Concrete Commands

protocol Moveable {

    func move(by offset: CGPoint)
}

class Shape: Moveable {

    var origin: CGPoint = .zero

    func move(by offset: CGPoint) {
        self.origin = self.origin.applying(.init(translationX: offset.x, y: offset.y))
    }
}

struct MoveCommand: Command {

    private let command: BlockCommand

    init(moveable: Moveable, offset: CGPoint) {
        self.command = BlockCommand(command: { moveable.move(by: offset) },
                                    inverseCommand: { moveable.move(by: CGPoint(x: -offset.x, y: -offset.y)) })
    }

    func invoke() {
        self.command.invoke()
    }

    func inversed() -> Command {
        return self.command.inversed()
    }
}


final class CommandInvoker {

    enum Error: Swift.Error {
        case undo
        case redo
    }

    private(set) var commands: [Command] = []
    private(set) var undoneCommands: [Command] = []

    func invoke(command: Command) {
        command.invoke()
        self.commands.append(command)
        self.undoneCommands.removeAll()
    }

    func undo(numberOfCommands: Int = 1) throws {
        guard self.commands.count >= numberOfCommands else { throw Error.undo }

        let commandsToUndo = self.commands.remove(last: numberOfCommands).reversed()
        commandsToUndo.forEach { command in
            command.inversed().invoke()
            self.undoneCommands.append(command)
        }
    }

    func redo(numberOfCommands: Int = 1) throws {
        guard self.undoneCommands.count >= numberOfCommands else { throw Error.redo }

        let commandsToRedo = self.undoneCommands.remove(first: numberOfCommands)
        commandsToRedo.forEach { command in
            command.invoke()
            self.commands.append(command)
        }
    }
}


//  MARK: - Tests

func expect(_ expectation: @autoclosure (Void) -> Bool) -> String {
    return expectation() ? "✅ ok" : "❌ failed"
}

let shape = Shape()
let commander = CommandInvoker()
let move = MoveCommand(moveable: shape, offset: CGPoint(x: 10.0, y: 5.0))

expect(shape.origin == .zero)

commander.invoke(command: move)
expect(shape.origin == CGPoint(x: 10.0, y: 5.0))
expect(commander.commands.count == 1)
expect(commander.undoneCommands.count == 0)

commander.invoke(command: move)
expect(shape.origin == CGPoint(x: 20.0, y: 10.0))
expect(commander.commands.count == 2)
expect(commander.undoneCommands.count == 0)

try! commander.undo()
expect(shape.origin == CGPoint(x: 10.0, y: 5.0))
expect(commander.commands.count == 1)
expect(commander.undoneCommands.count == 1)

try! commander.redo()
expect(shape.origin == CGPoint(x: 20.0, y: 10.0))
expect(commander.commands.count == 2)
expect(commander.undoneCommands.count == 0)

let groupedIdentityMove = GroupCommand(commands: [move, move.inversed()])
commander.invoke(command: groupedIdentityMove)
expect(shape.origin == CGPoint(x: 20.0, y: 10.0))
expect(commander.commands.count == 3)
expect(commander.undoneCommands.count == 0)

let groupedDoubleMove = GroupCommand(commands: [move, move])
commander.invoke(command: groupedDoubleMove.inversed())
expect(shape.origin == .zero)
expect(commander.commands.count == 4)
expect(commander.undoneCommands.count == 0)

while !commander.commands.isEmpty { try! commander.undo() }
expect(shape.origin == .zero)
expect(commander.commands.count == 0)
expect(commander.undoneCommands.count == 4)
