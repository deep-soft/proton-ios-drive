// Copyright (c) 2023 Proton AG
//
// This file is part of Proton Drive.
//
// Proton Drive is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Drive is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Drive. If not, see https://www.gnu.org/licenses/.

import Foundation

open class AsynchronousOperation: Operation {
    public enum State: String {
        case ready
        case executing
        case finished

        fileprivate var keyPath: String {
            "is\(rawValue.capitalized)"
        }
    }

    public var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        } didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }

    override public var isExecuting: Bool {
        state == .executing
    }

    override public var isFinished: Bool {
        state == .finished
    }

    override public var isAsynchronous: Bool {
        true
    }

    /// Should be overriden only with custom state handling.
    /// Put execution login into `main`.
    override public func start() {
        if isCancelled {
            state = .finished
            return
        }

        state = .executing
        main()
    }

    override public func cancel() {
        super.cancel()

        guard isExecuting else { return }
        state = .finished
    }
}
