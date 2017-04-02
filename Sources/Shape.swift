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

    var center: CGPoint { get set }

    func move(by offset: CGVector)
}

public protocol Displayable: class {

    var title: String { get set }
}

public class Shape: Moveable, Displayable {

    public var center: CGPoint = .zero
    public var title: String = ""

    public func move(by offset: CGVector) {
        self.center = self.center.applying(.init(translationX: offset.dx, y: offset.dy))
    }
}

// MARK: - Commands

public struct MoveCommand: Command {

    private let command: Command

    public init(moveable: Moveable, offset: CGVector) {
        let inverseOffset = CGVector(dx: -offset.dx, dy: -offset.dy)
        self.command = BlockCommand(command: { moveable.move(by: offset) },
                                    inverseCommand: { moveable.move(by: inverseOffset) })
    }

    public func invoke() {
        self.command.invoke()
    }

    public func inversed() -> Command {
        return self.command.inversed()
    }
}

public struct UpdateTitleCommand: Command {

    private let command: Command

    public init(displayable: Displayable, title: String) {
        let currentTitle = displayable.title
        self.command = BlockCommand(command: { displayable.title = title },
                                    inverseCommand: { displayable.title = currentTitle })
    }

    public func invoke() {
        self.command.invoke()
    }

    public func inversed() -> Command {
        return self.command.inversed()
    }
}

public struct CollissionDetectionCommand: Command {

    private let command: Command

    public init(moveables: [Moveable]) {
        let centerPoints = moveables.map { $0.center }
        self.command = BlockCommand(
            command: {
                // we assume a collission if any object has the same center as the first object
                guard moveables.filter({ $0.center == moveables[0].center }).count > 1 else { return }

                // simulate asynchronous execution
                let deadlineTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    for (index, moveable) in moveables.enumerated() {
                        moveable.move(by: CGVector(dx: index * 100, dy: 0))
                    }
                }
        }, inverseCommand: {
            zip(moveables, centerPoints).forEach { moveable, center in
                moveable.center = center
            }
        })
    }

    public func invoke() {
        self.command.invoke()
    }

    public func inversed() -> Command {
        return self.command.inversed()
    }
}

public struct LayoutCommand: Command {

    private let command: Command

    public init(moveables: [Moveable], target: CGPoint) {
        // Layout = Move objects + Collission Detection
        let moveCommands = moveables.map { moveable -> MoveCommand in
            let offsetToTarget = CGVector(dx: target.x - moveable.center.x, dy: target.y - moveable.center.y)
            return MoveCommand(moveable: moveable, offset: offsetToTarget)
        }

        self.command = GroupCommand(commands: moveCommands + [CollissionDetectionCommand(moveables: moveables)])
    }

    public func invoke() {
        self.command.invoke()
    }

    public func inversed() -> Command {
        return self.command.inversed()
    }
}
