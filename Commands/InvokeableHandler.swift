//
//  InvokeableHandler.swift
//  Commander
//
//  Created by Matthias Tretter on 03/05/2017.
//
//

import Foundation


/// an InvokeableHandler is any object, that can trigger actions based on a specific invokeable
/// All handlers are called by the Dispatcher, whenever an Invokeable is dispatched
public protocol InvokeableHandler: class {

    var isEnabled: Bool { get set }

    func handleInvokeable(_ invokeable: Invokeable)
}
