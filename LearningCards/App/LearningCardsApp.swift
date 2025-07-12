//
//  LearningCardsApp.swift
//  LearningCards
//
//  Created by Alexander on 04.07.2025.
//

import SwiftUI

@main
struct LearningCardsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AuthorizationView()
        }
    }
}
