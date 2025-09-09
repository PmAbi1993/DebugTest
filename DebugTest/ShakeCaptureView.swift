import SwiftUI
import UIKit

/// Captures UIEvent-based shakes (e.g., Simulator: ⌘⌃Z) and forwards to `ShakeDetector`.
/// Embed once near the root of your view hierarchy.
struct ShakeCaptureView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller {
        let vc = Controller()
        vc.view.isUserInteractionEnabled = false
        vc.view.backgroundColor = .clear
        return vc
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {}

    final class Controller: UIViewController {
        override var canBecomeFirstResponder: Bool { true }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            becomeFirstResponder()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            resignFirstResponder()
        }

        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                ShakeDetector.shared.trigger()
            }
        }
    }
}
