/// Simple playground to test an API that we can use for operation-based actions
/// to modify objects.
///
/// TODO:
/// - [ ] Asynchronous Commands (Futures?)
/// - [ ] Cancelable Commands (Result<T>?)

import Foundation


func main() {
    testBasics()
    testLayout()
    testValidation()
}

private func testBasics() {
    let undoManager = CommandUndoHandler()
    let commander = CommandDispatcher(validator: AppValidator(appMode: AppMode(mode: .full)))
    commander.handlers.append(undoManager)

    let shape = Shape()
    let move = MoveCommand(moveable: shape, offset: CGVector(dx: 10.0, dy: 5.0))

    // test preconditions
    expect(shape.center == .zero)
    expect(shape.title == "")

    // test move
    commander.invoke(move)
    expect(shape.center == CGPoint(x: 10.0, y: 5.0))
    expect(undoManager.commands.count == 1)
    expect(undoManager.undoneCommands.count == 0)

    commander.invoke(move)
    expect(shape.center == CGPoint(x: 20.0, y: 10.0))
    expect(undoManager.commands.count == 2)
    expect(undoManager.undoneCommands.count == 0)

    // test undo
    try! undoManager.undo()
    expect(shape.center == CGPoint(x: 10.0, y: 5.0))
    expect(undoManager.commands.count == 1)
    expect(undoManager.undoneCommands.count == 1)

    // test redo
    try! undoManager.redo()
    expect(shape.center == CGPoint(x: 20.0, y: 10.0))
    expect(undoManager.commands.count == 2)
    expect(undoManager.undoneCommands.count == 0)

    // test grouping
    let groupedIdentityMove = GroupCommand(commands: [move, move.inversed()])
    commander.invoke(groupedIdentityMove)
    expect(shape.center == CGPoint(x: 20.0, y: 10.0))
    expect(undoManager.commands.count == 3)
    expect(undoManager.undoneCommands.count == 0)

    let groupedDoubleMove = GroupCommand(commands: [move, move])
    commander.invoke(groupedDoubleMove.inversed())
    expect(shape.center == .zero)
    expect(undoManager.commands.count == 4)
    expect(undoManager.undoneCommands.count == 0)

    // test undo loop
    while !undoManager.commands.isEmpty { try! undoManager.undo() }
    expect(shape.center == .zero)
    expect(undoManager.commands.count == 0)
    expect(undoManager.undoneCommands.count == 4)

    // test undo/redo counts
    try! undoManager.redo(numberOfCommands: 4)
    expect(shape.center == .zero)
    expect(undoManager.commands.count == 4)
    expect(undoManager.undoneCommands.count == 0)

    try! undoManager.undo(numberOfCommands: 4)
    expect(shape.center == .zero)
    expect(undoManager.commands.count == 0)
    expect(undoManager.undoneCommands.count == 4)

    // test title setting
    let updateTitle = UpdateTitleCommand(displayable: shape, title: "A Shape")
    commander.invoke(updateTitle)
    expect(shape.center == .zero)
    expect(shape.title == "A Shape")
    expect(undoManager.commands.count == 1)
    expect(undoManager.undoneCommands.count == 0)

    let updateTitle2 = UpdateTitleCommand(displayable: shape, title: "A New Shape")
    commander.invoke(updateTitle2)
    expect(shape.title == "A New Shape")
    try! undoManager.undo()
    expect(shape.title == "A Shape")
}

private func testLayout() {
    let undoManager = CommandUndoHandler()
    let commander = CommandDispatcher(validator: AppValidator(appMode: AppMode(mode: .full)))
    commander.handlers.append(undoManager)

    let shapes = [Shape(), Shape(), Shape(), Shape(), Shape(), Shape(), Shape(), Shape(), Shape(), Shape()]
    for (index, shape) in zip(shapes.indices, shapes) {
        shape.title = "#\(index)"
        expect(shape.center == .zero, description: "Verifying Inital state for layout")
    }

    let layoutCommand = LayoutCommand(moveables: shapes, target: .zero)
    commander.invoke(layoutCommand)

    Thread.sleep(forTimeInterval: 1.0)

    for (index, shape) in zip(shapes.indices, shapes) {
        expect(shape.center.x == CGFloat(index * 100), description: "Verifying x for shape \(shape)")
        expect(shape.center.y == CGFloat(index * 10), description: "Verifying y for shape \(shape)")
    }

    try! undoManager.undo()

    Thread.sleep(forTimeInterval: 1.0)

    for shape in shapes {
        expect(shape.center == .zero, description: "Verifying center after undo")
    }
}

private func testValidation() {
    let commander = CommandDispatcher(validator: AppValidator(appMode: AppMode(mode: .readOnly)))

    let shape = Shape()
    shape.title = "Original Title"
    let updateCommand = UpdateTitleCommand(displayable: shape, title: "New Title")

    expect(shape.title == "Original Title", description: "Verifiying initial title of shape")
    commander.invoke(updateCommand)
    expect(shape.title == "Original Title", description: "Verifiying title of shape after forbidden command")
    expect(updateCommand.state == .forbidden, description: "Verifiying state of forbidden command")

    var output: TextOutputStream = ""
    let displayCommand = DisplayCommand(displayable: shape, outputStream: &output)
    commander.invoke(displayCommand)
    expect(displayCommand.state == .finished(timestamp: Date()), description: "Verifiying state of display command")
    expect((output as! String) == "Priting displayable with title: Original Title", description: "Verifiying output of display command")
}

@discardableResult
private func expect(_ expectation: @autoclosure (Void) -> Bool, description: String = "") -> String {
    let succeeded = expectation()
    var output = succeeded ? "✅" : "❌"
    if !description.isEmpty {
        output += " - \(description)"
    }

    print(output)
    return output
}

main()
