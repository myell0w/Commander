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

protocol Moveable: AnyObject {

    var uuid: UUID { get }
    var center: CGPoint { get set }

    func move(by offset: CGVector)
}

protocol Displayable: AnyObject {

    var title: String { get set }
}

final class Shape: Moveable, Displayable, CustomStringConvertible {

    private(set) public var uuid = UUID()
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

final class MoveCommand: Command {

    private let moveable: Moveable
    private let offset: CGVector
    private var inverseOffset: CGVector { return CGVector(dx: -self.offset.dx, dy: -self.offset.dy) }

    init(moveable: Moveable, offset: CGVector) {
        self.moveable = moveable
        self.offset = offset
    }

    convenience init(moveable: Moveable, target: CGPoint) {
        let offset = CGVector(dx: target.x - moveable.center.x, dy: target.y - moveable.center.y)
        self.init(moveable: moveable, offset: offset)
    }

    func invoke(context: InvocationContext? = nil) {
        self.moveable.move(by: self.offset)
    }

    func reverse(context: InvocationContext? = nil) {
        self.moveable.move(by: self.inverseOffset)
    }
}

final class UpdateTitleCommand: ProduceCommand {

    init(displayable: Displayable, title: String) {
        super.init { () -> Command in
            let currentTitle = displayable.title

            return BlockCommand(block: { displayable.title = title },
                                reverseBlock: { displayable.title = currentTitle })
        }
    }
}

final class CollissionDetectionCommand: Command {

    private let moveables: [Moveable]
    private lazy var command: Command = self.makeCommand()

    init(moveables: [Moveable]) {
        self.moveables = moveables
    }

    func invoke(context: InvocationContext? = nil) {
        self.command.invoke(context: context)
    }

    func reverse(context: InvocationContext? = nil) {
        self.command.reverse(context: context)
    }

    private func makeCommand() -> Command {
        let originalCenterPoints = Dictionary(uniqueKeysWithValues: self.moveables.map { ($0.uuid, $0.center) })

        return BlockCommand(
            block: {
                // simulate asynchronous execution
                let deadlineTime = DispatchTime.now() + .milliseconds(500)
                DispatchQueue.global().asyncAfter(deadline: deadlineTime) {
					let moveCommands = zip(self.moveables.indices, self.moveables).map { arg -> MoveCommand in
						let (index, moveable) = arg
						return MoveCommand(moveable: moveable, offset: CGVector(dx: index * 100, dy: 0))
                    }

                    let groupCommand = GroupCommand(commands: moveCommands)
                    groupCommand.invoke()
                }
        },
            reverseBlock: {
                let moveCommands = self.moveables.map { MoveCommand(moveable: $0, target: originalCenterPoints[$0.uuid]!) }
                let groupCommand = GroupCommand(commands: moveCommands)
                groupCommand.invoke()
        })
    }
}

final class LayoutCommand: ProduceCommand {

    init(moveables: [Moveable], target: CGPoint) {
        super.init { () -> Command in
            // Layout = Move objects + Collission Detection
            let moveCommands = zip(moveables.indices, moveables).map { arg -> MoveCommand in
                let (index, moveable) = arg
                let y = target.y + CGFloat(index) * 10.0
                return MoveCommand(moveable: moveable, target: CGPoint(x: target.x, y: y))
            }

            return GroupCommand(commands: moveCommands + [CollissionDetectionCommand(moveables: moveables)])
        }

    }
}

final class DisplayCommand: Invokeable {

    private let displayable: Displayable
    private let outputStreamPointer: UnsafeMutablePointer<TextOutputStream>

    init(displayable: Displayable, outputStream: UnsafeMutablePointer<TextOutputStream>) {
        self.displayable = displayable
        self.outputStreamPointer = outputStream
    }

    func invoke(context: InvocationContext? = nil) {
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
