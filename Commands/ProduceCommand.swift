//
//  ProduceCommand.swift
//  Commander
//
//  Created by Matthias Tretter on 11/05/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// A Command that can be used to produce another Command
/// This can be useful if the creation of a Command `B` depends on the
/// Results of Command `A`, but you still want to group them together into { A, B }
public final class ProduceCommand: BaseCommand {

    public typealias Producer = () -> Command

    private let producer: Producer

    // MARK: - Lifecycle

    public init(producer: @escaping Producer) {
        self.producer = producer
        super.init()
    }

    // MARK: - BaseCommand

    override public func makeCommand() -> Command {
        return self.producer()
    }
}
