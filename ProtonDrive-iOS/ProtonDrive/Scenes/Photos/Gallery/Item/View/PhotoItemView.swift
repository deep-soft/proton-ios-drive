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

import ProtonCore_UIFoundations
import SwiftUI

struct PhotoItemView<ViewModel: PhotoItemViewModelProtocol>: View {
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Button(action: viewModel.openPreview) {
            content
        }
    }

    private var content: some View {
        ZStack {
            ColorProvider.BackgroundDeep
            image
        }
        .overlay(alignment: .bottom) {
            viewModel.duration.map(makeDurationView)
        }
    }

    @ViewBuilder
    private var image: some View {
        if let imageData = viewModel.image {
            Image(uiImage: UIImage(data: imageData) ?? UIImage())
        }
    }

    private func makeDurationView(with duration: String) -> some View {
        HStack(spacing: 4) {
            Spacer()
            Text(duration)
                .font(.caption)
                .foregroundColor(ColorProvider.TextInverted)
            Image("ic-play-filled-background")
        }
        .padding(EdgeInsets(top: 4, leading: 6, bottom: 6, trailing: 6))
        .background {
            Image("video-background")
                .resizable(resizingMode: .tile)
        }
    }
}
