//
//  CommanderTests.swift
//  CommanderTests
//
//  Created by Matthias Tretter on 03/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import XCTest
@testable import Commander
@testable import Commands


class CommanderTests: XCTestCase {
    
    func testBasics() {
        let undoManager = CommandUndoManager()
        let commander = CommandDispatcher(validator: AppValidator(appMode: AppMode(mode: .full)))
        commander.handlers.append(undoManager)

        let shape = Shape()
        let move = { MoveCommand(moveable: shape, offset: CGVector(dx: 10.0, dy: 5.0)) }

        // test preconditions
        XCTAssertTrue(shape.center == .zero)
        XCTAssertTrue(shape.title == "")

        // test move
        commander.invoke(move())
        XCTAssertTrue(shape.center == CGPoint(x: 10.0, y: 5.0))
        XCTAssertTrue(undoManager.commands.count == 1)
        XCTAssertTrue(undoManager.undoneCommands.count == 0)

        commander.invoke(move())
        XCTAssertTrue(shape.center == CGPoint(x: 20.0, y: 10.0))
        XCTAssertTrue(undoManager.commands.count == 2)
        XCTAssertTrue(undoManager.undoneCommands.count == 0)

        // test undo
        try! undoManager.undo()
        XCTAssertTrue(shape.center == CGPoint(x: 10.0, y: 5.0))
        XCTAssertTrue(undoManager.commands.count == 1)
        XCTAssertTrue(undoManager.undoneCommands.count == 1)

        // test redo
        try! undoManager.redo()
        XCTAssertTrue(shape.center == CGPoint(x: 20.0, y: 10.0))
        XCTAssertTrue(undoManager.commands.count == 2)
        XCTAssertTrue(undoManager.undoneCommands.count == 0)

        // test grouping
        let groupedIdentityMove = GroupCommand(commands: [move(), InverseCommand(command: move())])
        commander.invoke(groupedIdentityMove)
        XCTAssertTrue(shape.center == CGPoint(x: 20.0, y: 10.0))
        XCTAssertTrue(undoManager.commands.count == 3)
        XCTAssertTrue(undoManager.undoneCommands.count == 0)

        let groupedDoubleMove = InverseCommand(command: GroupCommand(commands: [move(), move()]))
        commander.invoke(groupedDoubleMove)
        XCTAssertTrue(shape.center == .zero)
        XCTAssertTrue(undoManager.commands.count == 4)
        XCTAssertTrue(undoManager.undoneCommands.count == 0)

        // test undo loop
        while !undoManager.commands.isEmpty { try! undoManager.undo() }
        XCTAssertTrue(shape.center == .zero)
        XCTAssertTrue(undoManager.commands.count == 0)
        XCTAssertTrue(undoManager.undoneCommands.count == 4)

        // test undo/redo counts
        try! undoManager.redo(numberOfCommands: 4)
        XCTAssertTrue(shape.center == .zero)
        XCTAssertTrue(undoManager.commands.count == 4)
        XCTAssertTrue(undoManager.undoneCommands.count == 0)

        try! undoManager.undo(numberOfCommands: 4)
        XCTAssertTrue(shape.center == .zero)
        XCTAssertTrue(undoManager.commands.count == 0)
        XCTAssertTrue(undoManager.undoneCommands.count == 4)

        // test title setting
        let updateTitle = UpdateTitleCommand(displayable: shape, title: "A Shape")
        commander.invoke(updateTitle)
        XCTAssertTrue(shape.center == .zero)
        XCTAssertTrue(shape.title == "A Shape")
        XCTAssertTrue(undoManager.commands.count == 1)
        XCTAssertTrue(undoManager.undoneCommands.count == 0)

        let updateTitle2 = UpdateTitleCommand(displayable: shape, title: "A New Shape")
        commander.invoke(updateTitle2)
        XCTAssertTrue(shape.title == "A New Shape")
        try! undoManager.undo()
        XCTAssertTrue(shape.title == "A Shape")
    }

    func testLayout() {
        let undoManager = CommandUndoManager()
        let commander = CommandDispatcher(validator: AppValidator(appMode: AppMode(mode: .full)))
        commander.handlers.append(undoManager)

        let shapes = [Shape(), Shape(), Shape(), Shape(), Shape(), Shape(), Shape(), Shape(), Shape(), Shape()]
        for (index, shape) in zip(shapes.indices, shapes) {
            shape.title = "#\(index)"
            XCTAssertTrue(shape.center == .zero, "Verifying Inital state for layout")
        }

        let layoutCommand = LayoutCommand(moveables: shapes, target: .zero)
        commander.invoke(layoutCommand)

        Thread.sleep(forTimeInterval: 1.0)

        for (index, shape) in zip(shapes.indices, shapes) {
            XCTAssertTrue(shape.center.x == CGFloat(index * 100), "Verifying x for shape \(shape)")
            XCTAssertTrue(shape.center.y == CGFloat(index * 10), "Verifying y for shape \(shape)")
        }

        try! undoManager.undo()

        Thread.sleep(forTimeInterval: 1.0)

        for shape in shapes {
            XCTAssertTrue(shape.center == .zero, "Verifying center after undo")
        }
    }

    func testValidation() {
        let commander = CommandDispatcher(validator: AppValidator(appMode: AppMode(mode: .readOnly)))

        let shape = Shape()
        shape.title = "Original Title"
        let updateCommand = UpdateTitleCommand(displayable: shape, title: "New Title")

        XCTAssertTrue(shape.title == "Original Title", "Verifiying initial title of shape")
        commander.invoke(updateCommand)
        XCTAssertTrue(shape.title == "Original Title", "Verifiying title of shape after forbidden command")
        XCTAssertTrue(updateCommand.state == .forbidden, "Verifiying state of forbidden command")
        
        var output: TextOutputStream = ""
        let displayCommand = DisplayCommand(displayable: shape, outputStream: &output)
        commander.invoke(displayCommand)
        XCTAssertTrue(displayCommand.state == .finished(timestamp: Date()), "Verifiying state of display command")
        XCTAssertTrue((output as! String) == "Priting displayable with title: Original Title", "Verifiying output of display command")
    }

    func testScratchpad() {
        let shape = Shape()
        let commander = CommandDispatcher()
        let move = { MoveCommand(moveable: shape, offset: CGVector(dx: 10.0, dy: 5.0)) }

        let scratchpad = CommandDispatcher.makeScratchpad { dispatcher in
            dispatcher.invoke(move())
            dispatcher.invoke(move())
        }

        // Commands shouldn't be invoked yet
        XCTAssertEqual(scratchpad.commands.count, 2)
        XCTAssertEqual(shape.center, .zero)
        for command in scratchpad.commands {
            XCTAssertEqual(command.state, .ready)
        }

        commander.applyStore(scratchpad)
        XCTAssertEqual(scratchpad.commands.count, 0)
        XCTAssertEqual(shape.center, CGPoint(x: 20.0, y: 10.0))
        for command in scratchpad.commands {
            XCTAssertEqual(command.state, .finished(timestamp: Date()))
        }
    }
}
