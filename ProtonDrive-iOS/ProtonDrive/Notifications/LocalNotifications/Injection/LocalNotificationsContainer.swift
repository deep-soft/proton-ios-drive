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

import PDCore
import SwiftUI

final class LocalNotificationsContainer {
    private let factory = LocalNotificationsFactory()
    private let localNotificationsController: LocalNotificationsController
    private let controller: NotificationsPermissionsController
    private var coordinator: NotificationsPermissionsCoordinator?
    
    init(tower: Tower, windowScene: UIWindowScene) {
        localNotificationsController = factory.makeNotificationsController()
        let flowController = factory.makeFlowController()
        controller = factory.makePermissionsController(tower: tower, flowController: flowController)
        startPermissionsCoordinator(flowController: flowController, windowScene: windowScene)
    }
    
    private func startPermissionsCoordinator(flowController: NotificationsPermissionsFlowController, windowScene: UIWindowScene) {
        #if DEBUG
        if DebugConstants.commandLineContains(flags: [.uiTests, .skipNotificationPermissions]) {
            return
        }
        #endif
        coordinator = factory.makePermissionsCoordinator(controller: controller, flowController: flowController, windowScene: windowScene)
    }
}
