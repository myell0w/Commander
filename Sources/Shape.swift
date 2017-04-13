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

public final class MoveCommand: WrapperCommand {

    public let command: Command
    public var timestamp: Date?

    public init(moveable: Moveable, offset: CGVector) {
        let inverseOffset = CGVector(dx: -offset.dx, dy: -offset.dy)
        self.command = BlockCommand(command: { moveable.move(by: offset) },
                                    inverseCommand: { moveable.move(by: inverseOffset) })
    }

    public convenience init(moveable: Moveable, target: CGPoint) {
        let offset = CGVector(dx: target.x - moveable.center.x, dy: target.y - moveable.center.y)
        self.init(moveable: moveable, offset: offset)
    }
}

public final class UpdateTitleCommand: WrapperCommand {

    public let command: Command
    public var timestamp: Date?

    public init(displayable: Displayable, title: String) {
        let currentTitle = displayable.title
        self.command = BlockCommand(command: { displayable.title = title },
                                    inverseCommand: { displayable.title = currentTitle })
    }
}

public final class CollissionDetectionCommand: WrapperCommand, AsyncCommand {

    typealias MoveableID = UUID

    private let moveables: [Moveable]
    private var originalCenterPoints: [MoveableID: CGPoint] = [:]

    public lazy var command: Command = self.makeCommand()
    public var timestamp: Date?
    private(set) public var canceled: Bool = false

    public init(moveables: [Moveable]) {
        self.moveables = moveables
    }

    public func cancel() {
        self.canceled = true
    }

    private func makeCommand() -> Command {
        return BlockCommand(
            command: {
                self.originalCenterPoints = Dictionary(tuples: self.moveables.map { ($0.uuid, $0.center) })
                // we assume a collission if any object has the same center as the first object
                // guard self.moveables.filter({ $0.center == self.moveables[0].center }).count > 1 else { return }

                // simulate asynchronous execution
                let deadlineTime = DispatchTime.now() + .milliseconds(500)
                DispatchQueue.global().asyncAfter(deadline: deadlineTime) {
                    guard !self.canceled else { return }

                    for (index, moveable) in self.moveables.enumerated() {
                        moveable.move(by: CGVector(dx: index * 100, dy: 0))
                    }
                }
        },
            inverseCommand: {
                guard !self.canceled else { return }
                
                self.moveables.forEach { moveable in
                    guard let center = self.originalCenterPoints[moveable.uuid] else { return }

                    moveable.center = center
                }
        })
    }
}

public final class LayoutCommand: WrapperCommand, AsyncCommand {

    public let command: Command
    public var timestamp: Date?
    public var canceled: Bool {
        guard let asyncCommand = self.command as? AsyncCommand else { return false }

        return asyncCommand.canceled
    }

    public init(moveables: [Moveable], target: CGPoint) {
        // Layout = Move objects + Collission Detection
        let moveCommands = zip(moveables.indices, moveables).map { index, moveable -> MoveCommand in
            let y = target.y + CGFloat(index) * 10.0
            return MoveCommand(moveable: moveable, target: CGPoint(x: target.x, y: y))
        }

        self.command = GroupCommand(commands: moveCommands + [CollissionDetectionCommand(moveables: moveables)])
    }

    public func cancel() {
        guard let asyncCommand = self.command as? AsyncCommand else { return }

        asyncCommand.cancel()
    }
}
