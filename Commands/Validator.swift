//
//  CommandValidator.swift
//  Commander
//
//  Created by Matthias Tretter on 21/04/2017.
//
//

import Foundation


/// Validates whether a command is allowed to be invoked
public protocol Validator {

    func validate(invokeable: Invokeable) -> Bool
}
