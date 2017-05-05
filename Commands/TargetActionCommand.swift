//
//  TargetActionCommand.swift
//  Commander
//
//  Created by Matthias Tretter on 05/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// A command that uses the target/action pattern
public final class TargetActionCommand {

    fileprivate weak var target: NSObject?
    fileprivate let action: Selector
    fileprivate let inverseAction: Selector

    // (from Command) - Swift doesn't allow to move Properties to extensions (yet)
    public let isMutating: Bool
    public var state: State = .ready

    // MARK: - Lifecycle

    public init(target: NSObject?, action: Selector, inverseAction: Selector, isMutating: Bool = true) {
        self.target = target
        self.action = action
        self.inverseAction = inverseAction
        self.isMutating = isMutating
    }
}

// MARK: - Command

extension TargetActionCommand: Command {

    public func invoke() {
        guard let target = self.target else { return }

        self.state = .executing
        target.perform(self.action)
        self.finish()
    }

    public func inversed() -> Command {
        return TargetActionCommand(target: self.target,
                                   action: self.inverseAction,
                                   inverseAction: self.action,
                                   isMutating: self.isMutating)
    }
}
