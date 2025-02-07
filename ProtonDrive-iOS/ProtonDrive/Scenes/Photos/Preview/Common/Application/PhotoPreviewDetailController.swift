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
import Foundation

protocol PhotoPreviewDetailController: AnyObject {
    var photo: AnyPublisher<PhotoInfo, Never> { get }
    func execute(with id: PhotoId)
}

final class LocalPhotoPreviewDetailController: PhotoPreviewDetailController {
    private let repository: PhotoInfoRepository
    private let currentDetailController: PhotoPreviewCurrentDetailController
    private var cancellables = Set<AnyCancellable>()
    private let photoSubject = PassthroughSubject<PhotoInfo, Never>()

    var photo: AnyPublisher<PhotoInfo, Never> {
        photoSubject.eraseToAnyPublisher()
    }

    init(repository: PhotoInfoRepository, currentDetailController: PhotoPreviewCurrentDetailController) {
        self.repository = repository
        self.currentDetailController = currentDetailController
        subscribeToUpdates()
    }

    private func subscribeToUpdates() {
        repository.photo
            .sink { [weak self] info in
                self?.handleUpdate(info)
            }
            .store(in: &cancellables)
    }

    private func handleUpdate(_ info: PhotoInfo) {
        currentDetailController.setPhoto(info)
        photoSubject.send(info)
    }

    func execute(with id: PhotoId) {
        repository.execute(with: id)
    }
}
