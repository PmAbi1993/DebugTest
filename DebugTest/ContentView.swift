//
//  ContentView.swift
//  DebugTest
//
//  Created by Abhijith Pm on 8/9/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: DebugTestDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(DebugTestDocument()))
}
