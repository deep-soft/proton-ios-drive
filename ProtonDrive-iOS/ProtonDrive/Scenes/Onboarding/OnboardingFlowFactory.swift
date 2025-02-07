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

import SwiftUI
import PDCore

struct OnboardingFlowFactory {
    let pageViewModels: [OnboardingPageViewModel] = [
        .init(imageName: "onboarding-welcome", title: "Welcome to Proton Drive", text: "The creators of Proton Mail bring you end-to-end encrypted cloud storage from Switzerland."),
        
        .init(imageName: "onboarding-files", title: "All files at your fingertips", text: "Upload and view your files on the go. Zero-access technology guarantees only you have access."),
        
        .init(imageName: "onboarding-share", title: "Secure sharing", text: "Add password protection to make your shared files even more secure."),
    
        .init(imageName: "onboarding-privacy", title: "Enjoy your private space", text: "Make your cloud storage your own. Add personal photos, ID cards, and anything that needs to stay private."),
    ]
    
    func make(settings: LocalSettings) -> UIViewController {
        let flow = OnboardingFlow(settings: settings, pages: pageViewModels)
        let vc = UIHostingController(rootView: flow)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

#if DEBUG
struct OnboardingFlowTestsManager {
    
    private static let localSettings = LocalSettings(suite: Constants.appGroup)
    
    static func defaultOnboardingInTestsIfNeeded() {
        guard DebugConstants.commandLineContains(flags: [.uiTests, .defaultOnboarding]) else {
            return
        }
        localSettings.isOnboarded = false
        DebugConstants.removeCommandLine(flags: [.defaultOnboarding])
    }
    
    static func skipOnboardingInTestsIfNeeded() {
        guard DebugConstants.commandLineContains(flags: [.uiTests, .clearAllPreference, .skipOnboarding]) else {
            return
        }
        
        localSettings.isOnboarded = true
    }
}
#endif
