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

public extension Optional {
    func forceUnwrap(file: StaticString = #file, line: UInt = #line) -> Wrapped {
        switch self {
        case .some(let wrapped):
            return wrapped
        case .none:
            fatalError("Could not find: " + String(describing: Wrapped.self) + "\n" + "in \(file).", file: file, line: line)
        }
    }

    var isNil: Bool {
        return self == nil
    }

    var isNotNil: Bool {
        !isNil
    }
}

public extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
