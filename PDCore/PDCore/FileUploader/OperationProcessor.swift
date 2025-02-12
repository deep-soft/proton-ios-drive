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

public class OperationProcessor<O: IdentifiableOperation> {

    let processingQueue: OperationQueue
    private let scheduledOperations: NSMapTable<NSUUID, O>
    private let regulatingQueue: DispatchQueue

    public init(
        queue processingQueue: OperationQueue
    ) {
        self.processingQueue = processingQueue
        self.regulatingQueue = DispatchQueue(label: "\(type(of: self))".lowercased() + ".queue", attributes: .concurrent)
        self.scheduledOperations = NSMapTable(keyOptions: .copyIn, valueOptions: .weakMemory)
    }

    /// Adds the operation to an Operation queue as well as all of its first level dependencies.
    /// and stores wekly a reference to that operation so that it can be cancelled more easily.
    /// - Parameter op: Any IdentifiableOperation
    public final func addOperation(_ op: O) {
        scheduledOperations.setObject(op, forKey: op.id as NSUUID)
        processingQueue.addOperation(op)
        processingQueue.addOperations(op.dependencies, waitUntilFinished: false)
    }

    public final func cancelOperation(with id: UUID) {
        getProcessingOperation(with: id)?.cancel()
    }

    public final func cancellAllOperations() {
        processingQueue.cancelAllOperations()
    }

    public final func getProcessingOperation(with id: UUID) -> O? {
        scheduledOperations.object(forKey: id as NSUUID)
    }

    /// Returns an array of all Operations of type O
    /// Beware this method is inherently a race condition.
    /// - Returns: Scheduled Operations of type O
    public final func getAllScheduledOperations() -> [O] {
        processingQueue.operations.compactMap { $0 as? O }
    }

    public final var isProcessingOperations: Bool {
        scheduledOperations.count != .zero
    }
}
