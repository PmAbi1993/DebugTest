//
//  DebugTestApp.swift
//  DebugTest
//
//  Created by Abhijith Pm on 8/9/25.
//

import SwiftUI

@main
struct DebugTestApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: DebugTestDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
