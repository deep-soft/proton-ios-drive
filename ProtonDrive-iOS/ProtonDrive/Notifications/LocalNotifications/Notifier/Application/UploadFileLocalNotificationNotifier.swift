//
//  UploadFileLocalNotificationNotifier.swift
//  ProtonDrive
//
//  Created by Aaron HR on 1/30/23.
//  Copyright © 2023 ProtonMail. All rights reserved.
//

import Foundation
import Combine

protocol LocalNotificationNotifier {
    var publisher: AnyPublisher<LocalNotification, Never> { get }
}

final class UploadFileLocalNotificationNotifier: LocalNotificationNotifier {
    private var cancellables = Set<AnyCancellable>()

    private var isApplicationInBackground = false
    private var didShowNotificationInSession = false
    private let subject: PassthroughSubject<LocalNotification, Never>

    let publisher: AnyPublisher<LocalNotification, Never>

    init(
        didInterruptOnFileUploadPublisher: AnyPublisher<Void, Never>,
        didFindIssueOnFileUploadPublisher: AnyPublisher<Void, Never>,
        didChangeAppRunningStatePublisher: AnyPublisher<ApplicationRunningState, Never>,
        notificationsResource: LocalNotificationsResource
    ) {
        subject = PassthroughSubject<LocalNotification, Never>()
        publisher = subject.eraseToAnyPublisher()

        didChangeAppRunningStatePublisher
            .sink { [weak self] in self?.onAppStateDidChange(to: $0) }
            .store(in: &cancellables)

        didInterruptOnFileUploadPublisher
            .flatMap { notificationsResource.isAuthorized() }
            .filter { $0 }
            .sink { [weak self] _ in self?.showInterruptedNotification() }
            .store(in: &cancellables)

        didFindIssueOnFileUploadPublisher
            .flatMap { notificationsResource.isAuthorized() }
            .filter { $0 }
            .sink { [weak self] _ in self?.showFailedNotification() }
            .store(in: &cancellables)
    }

    private var canShowNotification: Bool {
        !didShowNotificationInSession && isApplicationInBackground
    }

    private func onAppStateDidChange(to state: ApplicationRunningState) {
        isApplicationInBackground = state == .background

        guard state == .foreground else { return }
        didShowNotificationInSession = false
    }

    private func showInterruptedNotification() {
        guard canShowNotification else { return }

        subject.send(.interruptedUpload)
        didShowNotificationInSession = true
    }

    private func showFailedNotification() {
        guard canShowNotification else { return }

        subject.send(.failedUpload)
        didShowNotificationInSession = true
    }
}
