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

    func move(by offset: CGPoint)
}

public protocol Displayable: class {

    var title: String { get set }
}

public class Shape: Moveable, Displayable {

    var origin: CGPoint = .zero
    public var title: String = ""

    public func move(by offset: CGPoint) {
        self.origin = self.origin.applying(.init(translationX: offset.x, y: offset.y))
    }
}

// MARK: - Commands

public struct MoveCommand: Command {

    private let command: BlockCommand

    public init(moveable: Moveable, offset: CGPoint) {
        self.command = BlockCommand(command: { moveable.move(by: offset) },
                                    inverseCommand: { moveable.move(by: CGPoint(x: -offset.x, y: -offset.y)) })
    }

    public func invoke() {
        self.command.invoke()
    }

    public func inversed() -> Command {
        return self.command.inversed()
    }
}

public struct UpdateTitleCommand: Command {

    private let command: BlockCommand

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
