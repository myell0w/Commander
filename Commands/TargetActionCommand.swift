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

    private weak var target: NSObject?
    private let action: Selector
    private let reverseAction: Selector

    // MARK: - Lifecycle

    public init(target: NSObject, action: Selector, reverseAction: Selector) {
        self.target = target
        self.action = action
        self.reverseAction = reverseAction
    }
}

// MARK: - Command

extension TargetActionCommand: Command {

    public func invoke(context: InvocationContext? = nil) {
        _ = self.target?.perform(self.action)
    }

    public func reverse(context: InvocationContext? = nil) {
        _ = self.target?.perform(self.reverseAction)
    }
}
