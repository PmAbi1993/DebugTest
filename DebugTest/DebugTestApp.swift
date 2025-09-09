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
    init() {
        #if DEBUG
        Debugger.enable()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            NetCaptView()
                .preferredColorScheme(.dark)
                .mirrorOnShake()
        }
    }
}
