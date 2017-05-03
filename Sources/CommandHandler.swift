//
//  CommandHandler.swift
//  Commander
//
//  Created by Matthias Tretter on 03/05/2017.
//
//

import Foundation


public protocol CommandHandler {

    func handleCommand(_ command: Command)
}
