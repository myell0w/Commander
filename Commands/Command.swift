//
//  Command.swift
//  Commander
//
//  Created by Matthias Tretter on 02/04/2017.
//
//

import Foundation


/// A Command is an Invokable that mutates state and needs to be reversible
public protocol Command: Invokeable {

    func reverse()
}
