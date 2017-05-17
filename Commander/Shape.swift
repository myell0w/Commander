//
//  Shape.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation
import CoreGraphics
import Commands


// MARK: - Model

protocol Moveable: class {

    var uuid: UUID { get }
    var center: CGPoint { get set }

    func move(by offset: CGVector)
}

protocol Displayable: class {

    var title: String { get set }
}

final class Shape: Moveable, Displayable, CustomStringConvertible {

    private(set) public var uuid = UUID
    var center: CGPoint = .zero
    var title: String = ""

    func move(by offset: CGVector) {
        self.center = self.center.applying(.init(translationX: offset.dx, y: offset.dy))
    }

    var description: String {
        return "<Shape \(self.title), center = \(self.center), uuid = \(self.uuid)>"
    }
}

// MARK: - Commands

final class MoveCommand: BaseCommand {

    private let moveable: Moveable
    private let offset: CGVector

    init(moveable: Moveable, offset: CGVector) {
        self.moveable = moveable
        self.offset = offset
        super.init()
    }

    convenience init(moveable: Moveable, target: CGPoint) {
        let offset = CGVector(dx: target.x - moveable.center.x, dy: target.y - moveable.center.y)
        self.init(moveable: moveable, offset: offset)
    }

    override func makeCommand() -> Command {
        let inverseOffset = CGVector(dx: -self.offset.dx, dy: -self.offset.dy)

        return BlockCommand(block: { self.moveable.move(by: self.offset) },
                            reverseBlock: { self.moveable.move(by: inverseOffset) })
    }
}

final class UpdateTitleCommand: BaseCommand {

    private let displayable: Displayable
    private let title: String

    init(displayable: Displayable, title: String) {
        self.displayable = displayable
        self.title = title
        super.init()
    }

    override func makeCommand() -> Command {
        let currentTitle = self.displayable.title

        return BlockCommand(block: { self.displayable.title = self.title },
                            reverseBlock: { self.displayable.title = currentTitle })
    }
}

final class CollissionDetectionCommand: BaseCommand {

    private let moveables: [Moveable]

    init(moveables: [Moveable]) {
        self.moveables = moveables
        super.init()
    }

    override func makeCommand() -> Command {
        let originalCenterPoints = Dictionary(tuples: self.moveables.map { ($0.uuid, $0.center) })

        return BlockCommand(
            block: {
                // simulate asynchronous execution
                let deadlineTime = DispatchTime.now() + .milliseconds(500)
                DispatchQueue.global().asyncAfter(deadline: deadlineTime) {
                    let moveCommands = zip(self.moveables.indices, self.moveables).map { index, moveable in
                        return MoveCommand(moveable: moveable, offset: CGVector(dx: index * 100, dy: 0))
                    }

                    let groupCommand = GroupCommand(commands: moveCommands)
                    groupCommand.invoke()
                }
        },
            reverseBlock: {
                let moveCommands = self.moveables.map {
                    return MoveCommand(moveable: $0, target: originalCenterPoints[$0.uuid]!)
                }

                let groupCommand = GroupCommand(commands: moveCommands)
                groupCommand.invoke()
        })
    }
}

final class LayoutCommand: BaseCommand {

    private let moveables: [Moveable]
    private let target: CGPoint

    init(moveables: [Moveable], target: CGPoint) {
        self.moveables = moveables
        self.target = target
        super.init()
    }

    override func makeCommand() -> Command {
        // Layout = Move objects + Collission Detection
        let moveCommands = zip(self.moveables.indices, self.moveables).map { index, moveable -> MoveCommand in
            let y = self.target.y + CGFloat(index) * 10.0
            return MoveCommand(moveable: moveable, target: CGPoint(x: self.target.x, y: y))
        }

        return GroupCommand(commands: moveCommands + [CollissionDetectionCommand(moveables: moveables)])
    }
}

final class DisplayCommand: BaseQuery {

    private let displayable: Displayable
    private let outputStreamPointer: UnsafeMutablePointer<TextOutputStream>

    init(displayable: Displayable, outputStream: UnsafeMutablePointer<TextOutputStream>) {
        self.displayable = displayable
        self.outputStreamPointer = outputStream
    }

    override func performQuery() {
        self.outputStreamPointer.pointee.write("Priting displayable with title: \(self.displayable.title)")
    }
}

// MARK: - Validation

protocol AppDecision {

    func canEdit() -> Bool
}

final class AppMode: AppDecision {

    enum Mode {
        case readOnly
        case full
    }

    private let mode: Mode

    init(mode: Mode) {
        self.mode = mode
    }

    func canEdit() -> Bool {
        switch self.mode {
        case .readOnly:
            return false
        case .full:
            return true
        }
    }

}

final class AppValidator: Validator {

    let appMode: AppDecision

    // MARK: - Lifecycle

    init(appMode: AppDecision) {
        self.appMode = appMode
    }

    // MARK: - Validator
    
    func validate(invokeable: Invokeable) -> Bool {
        guard invokeable is Command else { return true }
        
        return self.appMode.canEdit()
    }
}
