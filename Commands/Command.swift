//
//  Command.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


// MARK: - Command

/// The base interface for any executable command, needs to be inversable
public protocol Command: Invokeable {

    func inverse()
}
