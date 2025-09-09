//
//  DebugTestApp.swift
//  DebugTest
//
//  Created by Abhijith Pm on 8/9/25.
//

import SwiftUI
import ShakeMirror
@main
struct DebugTestApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .preferredColorScheme(.dark)
                .mirrorOnShake()
        }
    }
}
