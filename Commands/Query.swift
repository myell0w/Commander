//
//  Query.swift
//  Commander
//
//  Created by Matthias Tretter on 11/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// A query is an Invokable, that has no side effects
public protocol Query: Invokeable { }


/// Convenience Base Implementation of the Query Protocol
open class BaseQuery {

    // (from Invokeable) - Swift doesn't allow to move Properties to extensions (yet)
    public var state: State = .ready
    public var uuid: Identifier

    // MARK: - Lifecycle

    public init(uuid: Identifier = UUID()) {
        self.uuid = uuid
    }

    // MARK: - BaseQuery

    open func performQuery() {
        fatalError("Subclasses must implement")
    }
}

// MARK: - Query

extension BaseQuery: Query {

    public func invoke() {
        self.state = .executing
        self.performQuery()
        self.finish()
    }
}
