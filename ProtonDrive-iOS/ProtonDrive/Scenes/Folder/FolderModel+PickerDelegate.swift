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

import UIKit
import PDCore

enum PickerError: Error, LocalizedError {
    case importFailures(errors: [Error])
    
    var errorDescription: String? {
        switch self {
        case let .importFailures(errors):
            let file = errors.count > 1 ? "files" : "file"
            let title = errors.first?.localizedDescription ?? ""
            return "Failed to import \(errors.count) \(file): \(title)"
        }
    }
}

extension FolderModel: PickerDelegate {
    func picker(didFinishPicking items: [Result<URL, Error>]) {
        var errors = [Error]()
        for item in items {
            switch item {
            case .success(let fileURL):
                uploadFile(fileURL, to: currentFolder)
            case .failure(let error):
                errors.append(error)
            }
        }
        if !errors.isEmpty {
            let error = PickerError.importFailures(errors: errors)
            errorSubject.send(error)
        }
    }
}

private extension FolderModel {
    var currentFolder: Folder {
        node
    }
}
