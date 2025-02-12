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

protocol PhotoPreviewDetailViewModelProtocol: ObservableObject {
    var state: PhotoPreviewDetailState? { get }
    func viewDidLoad()
    func toggleMode()
    func setActive()
    func share()
}

enum PhotoPreviewDetailState: Equatable {
    case loading(text: String, thumbnail: Data?)
    case preview(PhotoFullPreview)
}

final class PhotoPreviewDetailViewModel: PhotoPreviewDetailViewModelProtocol {
    private let thumbnailController: ThumbnailController
    private let modeController: PhotosPreviewModeController
    private let previewController: PhotosPreviewController
    private let detailController: PhotoPreviewDetailController
    private let fullPreviewController: PhotoFullPreviewController
    private let id: PhotoId
    private let coordinator: PhotoPreviewDetailCoordinator
    private var cancellables = Set<AnyCancellable>()

    @Published var state: PhotoPreviewDetailState?

    init(thumbnailController: ThumbnailController, modeController: PhotosPreviewModeController, previewController: PhotosPreviewController, detailController: PhotoPreviewDetailController, fullPreviewController: PhotoFullPreviewController, id: PhotoId, coordinator: PhotoPreviewDetailCoordinator) {
        self.thumbnailController = thumbnailController
        self.modeController = modeController
        self.previewController = previewController
        self.detailController = detailController
        self.fullPreviewController = fullPreviewController
        self.id = id
        self.coordinator = coordinator
        subscribeToUpdates()
    }

    deinit {
        fullPreviewController.clear()
    }

    func viewDidLoad() {
        if thumbnailController.getImage() == nil {
            thumbnailController.load()
        }
        reloadData()
    }

    func toggleMode() {
        modeController.toggle()
    }

    func setActive() {
        previewController.setCurrent(id)
        detailController.execute(with: id)
    }

    func share() {
        if let fullPreview = fullPreviewController.getPreview() {
            coordinator.openShare(with: fullPreview)
        }
    }

    private func subscribeToUpdates() {
        thumbnailController.updatePublisher
            .sink { [weak self] _ in
                self?.reloadData()
            }
            .store(in: &cancellables)
        fullPreviewController.updatePublisher
            .sink { [weak self] preview in
                self?.reloadData()
            }
            .store(in: &cancellables)
    }

    private func reloadData() {
        let state = makeNewState()
        if self.state != state {
            self.state = state
        }
    }

    private func makeNewState() -> PhotoPreviewDetailState {
        if let fullPreview = fullPreviewController.getPreview() {
            return .preview(fullPreview)
        } else {
            return .loading(text: "Loading...", thumbnail: thumbnailController.getImage())
        }
    }
}
