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

import Combine

protocol PhotoLibraryAssetsInteractor {
    var error: AnyPublisher<Error, Never> { get }
    func execute(with identifiers: PhotoIdentifiers)
}

final class LocalPhotoLibraryAssetsInteractor: PhotoLibraryAssetsInteractor {
    private let resource: PhotoLibraryAssetsQueueResource
    private let policy: PhotoLibraryFilterPolicy
    private let importInteractor: PhotoImportInteractor
    private let errorSubject = PassthroughSubject<Error, Never>()
    private var cancellables = Set<AnyCancellable>()

    var error: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    init(resource: PhotoLibraryAssetsQueueResource, policy: PhotoLibraryFilterPolicy, importInteractor: PhotoImportInteractor) {
        self.resource = resource
        self.policy = policy
        self.importInteractor = importInteractor
        subscribeToUpdates()
    }

    private func subscribeToUpdates() {
        resource.results
            .sink { [weak self] result in
                self?.handle(result)
            }
            .store(in: &cancellables)
    }

    private func handle(_ result: PhotoAssetCompoundsResult) {
        switch result {
        case let .success(compounds):
            let filteredCompounds = policy.filterCompounds(compounds)
            importInteractor.execute(with: filteredCompounds)
        case let .failure(error):
            errorSubject.send(error)
        }
    }

    func execute(with identifiers: PhotoIdentifiers) {
        let validIdentifiers = policy.filterIdentifiers(identifiers)
        resource.execute(with: validIdentifiers)
    }
}