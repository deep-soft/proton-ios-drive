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

public extension Progress {
    typealias UnitOfWork = Int

    convenience init(unitsOfWork: UnitOfWork) {
        self.init(totalUnitCount: Int64(unitsOfWork))
    }

    var unitsOfWorkCompleted: UnitOfWork {
        get { UnitOfWork(completedUnitCount) }
        set { completedUnitCount = Int64(newValue) }
    }

    var totalUnitsOfWork: UnitOfWork {
        get { UnitOfWork(totalUnitCount) }
        set { totalUnitCount = Int64(newValue) }
    }

    func modifyTotalUnitsOfWork(by newUnitsOfWork: Int) {
        let initial = totalUnitsOfWork
        totalUnitsOfWork = initial + newUnitsOfWork
    }

    func addChild(_ child: Progress, pending unitsOfWork: UnitOfWork) {
        addChild(child, withPendingUnitCount: Int64(unitsOfWork))
    }

    func complete(_ units: UnitOfWork) {
        unitsOfWorkCompleted += units
    }

    func complete() {
        completedUnitCount = totalUnitCount
    }
}

public extension Progress {

    func child(pending unitsOfWork: UnitOfWork = .zero) -> Progress {
        let child = Progress(unitsOfWork: unitsOfWork)
        addChild(child, pending: unitsOfWork)
        return child
    }

}
