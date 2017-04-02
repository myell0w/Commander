//
//import XCTest
//
//
//final class CommanderTests: XCTestCase {
//
//    let shape = Shape()
//    let commander = CommandDispatcher()
//
//    func testCommander() {
//        let move = MoveCommand(moveable: shape, offset: CGPoint(x: 10.0, y: 5.0))
//
//        // test preconditions
//        XCTAssertTrue(shape.origin == .zero)
//        XCTAssertTrue(shape.title == "")
//
//        // test move
//        commander.invoke(command: move)
//        XCTAssertTrue(shape.origin == CGPoint(x: 10.0, y: 5.0))
//        XCTAssertTrue(commander.commands.count == 1)
//        XCTAssertTrue(commander.undoneCommands.count == 0)
//
//        commander.invoke(command: move)
//        XCTAssertTrue(shape.origin == CGPoint(x: 20.0, y: 10.0))
//        XCTAssertTrue(commander.commands.count == 2)
//        XCTAssertTrue(commander.undoneCommands.count == 0)
//
//        // test undo
//        try! commander.undo()
//        XCTAssertTrue(shape.origin == CGPoint(x: 10.0, y: 5.0))
//        XCTAssertTrue(commander.commands.count == 1)
//        XCTAssertTrue(commander.undoneCommands.count == 1)
//
//        // test redo
//        try! commander.redo()
//        XCTAssertTrue(shape.origin == CGPoint(x: 20.0, y: 10.0))
//        XCTAssertTrue(commander.commands.count == 2)
//        XCTAssertTrue(commander.undoneCommands.count == 0)
//
//        // test grouping
//        let groupedIdentityMove = GroupCommand(commands: [move, move.inversed()])
//        commander.invoke(command: groupedIdentityMove)
//        XCTAssertTrue(shape.origin == CGPoint(x: 20.0, y: 10.0))
//        XCTAssertTrue(commander.commands.count == 3)
//        XCTAssertTrue(commander.undoneCommands.count == 0)
//
//        let groupedDoubleMove = GroupCommand(commands: [move, move])
//        commander.invoke(command: groupedDoubleMove.inversed())
//        XCTAssertTrue(shape.origin == .zero)
//        XCTAssertTrue(commander.commands.count == 4)
//        XCTAssertTrue(commander.undoneCommands.count == 0)
//
//        // test undo loop
//        while !commander.commands.isEmpty { try! commander.undo() }
//        XCTAssertTrue(shape.origin == .zero)
//        XCTAssertTrue(commander.commands.count == 0)
//        XCTAssertTrue(commander.undoneCommands.count == 4)
//
//        // test undo/redo counts
//        try! commander.redo(numberOfCommands: 4)
//        XCTAssertTrue(shape.origin == .zero)
//        XCTAssertTrue(commander.commands.count == 4)
//        XCTAssertTrue(commander.undoneCommands.count == 0)
//
//        try! commander.undo(numberOfCommands: 4)
//        XCTAssertTrue(shape.origin == .zero)
//        XCTAssertTrue(commander.commands.count == 0)
//        XCTAssertTrue(commander.undoneCommands.count == 4)
//
//        // test title setting
////        let updateTitle = UpdateTitleCommand(displayable: shape, title: "A Shape")
////        commander.invoke(command: updateTitle)
////        XCTAssertTrue(shape.origin == .zero)
////        XCTAssertTrue(shape.title == "A Shape")
////        XCTAssertTrue(commander.commands.count == 1)
////        XCTAssertTrue(commander.undoneCommands.count == 0)
//    }
//}
