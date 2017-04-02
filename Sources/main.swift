/// Simple playground to test an API that we can use for operation-based actions
/// to modify objects.
///
/// TODO:
/// - [ ] Asynchronous Commands (Futures?)
/// - [ ] Cancelable Commands (Result<T>?)

import Foundation


func main() {
    let shape = Shape()
    let commander = CommandDispatcher()

    let move = MoveCommand(moveable: shape, offset: CGVector(dx: 10.0, dy: 5.0))

    // test preconditions
    expect(shape.center == .zero)
    expect(shape.title == "")

    // test move
    commander.invoke(command: move)
    expect(shape.center == CGPoint(x: 10.0, y: 5.0))
    expect(commander.commands.count == 1)
    expect(commander.undoneCommands.count == 0)

    commander.invoke(command: move)
    expect(shape.center == CGPoint(x: 20.0, y: 10.0))
    expect(commander.commands.count == 2)
    expect(commander.undoneCommands.count == 0)

    // test undo
    try! commander.undo()
    expect(shape.center == CGPoint(x: 10.0, y: 5.0))
    expect(commander.commands.count == 1)
    expect(commander.undoneCommands.count == 1)

    // test redo
    try! commander.redo()
    expect(shape.center == CGPoint(x: 20.0, y: 10.0))
    expect(commander.commands.count == 2)
    expect(commander.undoneCommands.count == 0)

    // test grouping
    let groupedIdentityMove = GroupCommand(commands: [move, move.inversed()])
    commander.invoke(command: groupedIdentityMove)
    expect(shape.center == CGPoint(x: 20.0, y: 10.0))
    expect(commander.commands.count == 3)
    expect(commander.undoneCommands.count == 0)

    let groupedDoubleMove = GroupCommand(commands: [move, move])
    commander.invoke(command: groupedDoubleMove.inversed())
    expect(shape.center == .zero)
    expect(commander.commands.count == 4)
    expect(commander.undoneCommands.count == 0)

    // test undo loop
    while !commander.commands.isEmpty { try! commander.undo() }
    expect(shape.center == .zero)
    expect(commander.commands.count == 0)
    expect(commander.undoneCommands.count == 4)

    // test undo/redo counts
    try! commander.redo(numberOfCommands: 4)
    expect(shape.center == .zero)
    expect(commander.commands.count == 4)
    expect(commander.undoneCommands.count == 0)

    try! commander.undo(numberOfCommands: 4)
    expect(shape.center == .zero)
    expect(commander.commands.count == 0)
    expect(commander.undoneCommands.count == 4)

    // test title setting
    let updateTitle = UpdateTitleCommand(displayable: shape, title: "A Shape")
    commander.invoke(command: updateTitle)
    expect(shape.center == .zero)
    expect(shape.title == "A Shape")
    expect(commander.commands.count == 1)
    expect(commander.undoneCommands.count == 0)

    let updateTitle2 = UpdateTitleCommand(displayable: shape, title: "A New Shape")
    commander.invoke(command: updateTitle2)
    expect(shape.title == "A New Shape")
    try! commander.undo()
    expect(shape.title == "A Shape")
}

@discardableResult
private func expect(_ expectation: @autoclosure (Void) -> Bool, description: String = "") -> String {
    var output = expectation() ? "✅" : "❌"
    if !description.isEmpty {
        output += " - \(description)"
    }

    print(output)
    return output
}

main()
