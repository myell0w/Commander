//
//  Shape.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


// MARK: - Model

public protocol Moveable: class {

    var uuid: UUID { get }
    var center: CGPoint { get set }

    func move(by offset: CGVector)
}

public protocol Displayable: class {

    var title: String { get set }
}

public final class Shape: Moveable, Displayable, CustomStringConvertible {

    private(set) public var uuid = UUID()
    public var center: CGPoint = .zero
    public var title: String = ""

    public func move(by offset: CGVector) {
        self.center = self.center.applying(.init(translationX: offset.dx, y: offset.dy))
    }

    public var description: String {
        return "<Shape \(self.title), center = \(self.center), uuid = \(self.uuid)>"
    }
}

// MARK: - Commands

public final class MoveCommand: BaseCommand {

    private let moveable: Moveable
    private let offset: CGVector

    public init(moveable: Moveable, offset: CGVector) {
        self.moveable = moveable
        self.offset = offset
        super.init()
    }

    public convenience init(moveable: Moveable, target: CGPoint) {
        let offset = CGVector(dx: target.x - moveable.center.x, dy: target.y - moveable.center.y)
        self.init(moveable: moveable, offset: offset)
    }

    override func makeCommand() -> Command? {
        let inverseOffset = CGVector(dx: -self.offset.dx, dy: -self.offset.dy)

        return BlockCommand(command: { self.moveable.move(by: self.offset) },
                            inverseCommand: { self.moveable.move(by: inverseOffset) })
    }
}

public final class UpdateTitleCommand: BaseCommand {

    private let displayable: Displayable
    private let title: String

    public init(displayable: Displayable, title: String) {
        self.displayable = displayable
        self.title = title
    }

    override func makeCommand() -> Command? {
        let currentTitle = self.displayable.title

        return BlockCommand(command: { self.displayable.title = self.title },
                            inverseCommand: { self.displayable.title = currentTitle })
    }
}

public final class CollissionDetectionCommand: BaseCommand {

    private let moveables: [Moveable]
    public var isAsynchronous: Bool {
        return true
    }

    public init(moveables: [Moveable]) {
        self.moveables = moveables
    }

    override func makeCommand() -> Command? {
        let originalCenterPoints = Dictionary(tuples: self.moveables.map { ($0.uuid, $0.center) })

        return BlockCommand(
            command: {
                // simulate asynchronous execution
                let deadlineTime = DispatchTime.now() + .milliseconds(500)
                DispatchQueue.global().asyncAfter(deadline: deadlineTime) {
                    let moveCommands = zip(self.moveables.indices, self.moveables).map { index, moveable in
                        return MoveCommand(moveable: moveable, offset: CGVector(dx: index * 100, dy: 0))
                    }

                    let groupCommand = GroupCommand(commands: moveCommands)
                    groupCommand.invoke()
                    self.finish()
                }
        },
            inverseCommand: {
                let moveCommands = self.moveables.map {
                    return MoveCommand(moveable: $0, target: originalCenterPoints[$0.uuid]!)
                }

                let groupCommand = GroupCommand(commands: moveCommands)
                groupCommand.invoke()
        })
    }
}

public final class LayoutCommand: BaseCommand {

    private let moveables: [Moveable]
    private let target: CGPoint

    public init(moveables: [Moveable], target: CGPoint) {
        self.moveables = moveables
        self.target = target
    }

    override func makeCommand() -> Command? {
        // Layout = Move objects + Collission Detection
        let moveCommands = zip(self.moveables.indices, self.moveables).map { index, moveable -> MoveCommand in
            let y = self.target.y + CGFloat(index) * 10.0
            return MoveCommand(moveable: moveable, target: CGPoint(x: self.target.x, y: y))
        }

        return GroupCommand(commands: moveCommands + [CollissionDetectionCommand(moveables: moveables)])
    }
}
