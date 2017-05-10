//
//  CommandHandler.swift
//  Commander
//
//  Created by Matthias Tretter on 03/05/2017.
//
//

import Foundation


/// a CommandHandler is any object, that can trigger actions based on a specific command
public protocol CommandHandler: class {

    var isEnabled: Bool { get set }

    func handleCommand(_ command: Command)
}
