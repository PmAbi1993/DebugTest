import Foundation
import CoreMotion
import Combine
import SwiftUI

/// A lightweight, app-wide shake detector based on Core Motion.
/// - Posts NotificationCenter event `ShakeDetector.notification`
/// - Exposes a Combine `publisher`
/// - Provides a SwiftUI `.onShake {}` modifier for convenience
public final class ShakeDetector: ObservableObject {
    public static let shared = ShakeDetector()
    public static let notification = Notification.Name("ShakeDetector.didDetectShake")

    private let motionManager = CMMotionManager()
    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.name = "ShakeDetector.MotionQueue"
        q.qualityOfService = .userInitiated
        return q
    }()

    private let subject = PassthroughSubject<Void, Never>()
    public var publisher: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    private var isRunning = false
    private var lastShakeDate: Date?

    /// Minimum interval to prevent duplicate triggers for one physical shake.
    private let debounceInterval: TimeInterval = 0.8

    /// Sensitivity threshold for `userAcceleration` magnitude (in g's).
    /// Typical shake peaks range ~2.0–3.5g depending on device and vigor.
    public var threshold: Double = 2.2

    private init() {}

    /// Manually trigger a shake event (used by UIEvent-based fallback, e.g., Simulator).
    public func trigger() {
        let now = Date()
        if let last = lastShakeDate, now.timeIntervalSince(last) < debounceInterval {
            return
        }
        lastShakeDate = now
        emit()
    }

    /// Starts motion updates if not already running.
    public func start() {
        guard !isRunning else { return }
        isRunning = true

        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motion, error in
                guard let self else { return }
                if let error { self.handleError(error); return }
                guard let motion else { return }

                let a = motion.userAcceleration
                let magnitude = sqrt(a.x*a.x + a.y*a.y + a.z*a.z)
                self.evaluate(magnitude: magnitude)
            }
        } else if motionManager.isAccelerometerAvailable {
            // Fallback: includes gravity (~1g at rest). Use a higher threshold.
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0
            motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, error in
                guard let self else { return }
                if let error { self.handleError(error); return }
                guard let data else { return }

                let x = data.acceleration.x
                let y = data.acceleration.y
                let z = data.acceleration.z
                let magnitude = sqrt(x*x + y*y + z*z)
                self.evaluate(magnitude: magnitude, includesGravity: true)
            }
        } else {
            print("[ShakeDetector] Motion data not available on this device.")
        }
    }

    /// Stops motion updates if running.
    public func stop() {
        guard isRunning else { return }
        isRunning = false
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
    }

    private func evaluate(magnitude: Double, includesGravity: Bool = false) {
        var thresh = threshold
        if includesGravity {
            // With gravity included, rest magnitude ~1g; bump the threshold.
            thresh = max(threshold + 1.0, 2.7)
        }

        if magnitude >= thresh {
            let now = Date()
            if let last = lastShakeDate, now.timeIntervalSince(last) < debounceInterval {
                return
            }
            lastShakeDate = now

            DispatchQueue.main.async {
                self.emit()
            }
        }
    }

    private func handleError(_ error: Error) {
        print("[ShakeDetector] Motion error: \(error)")
    }

    private func emit() {
        NotificationCenter.default.post(name: ShakeDetector.notification, object: nil)
        subject.send()
    }
}

// MARK: - SwiftUI Convenience
public extension View {
    /// React to device shake events detected globally.
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.onReceive(ShakeDetector.shared.publisher.receive(on: RunLoop.main)) { _ in
            action()
        }
    }
}
