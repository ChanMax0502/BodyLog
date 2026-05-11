import Foundation
import LocalAuthentication

enum BiometricKind {
    case faceID
    case touchID
    case none
}

struct BiometricAuth {
    static let shared = BiometricAuth()

    func availability() -> BiometricKind {
        let ctx = LAContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        switch ctx.biometryType {
        case .faceID:  return .faceID
        case .touchID: return .touchID
        default:       return .none
        }
    }

    func authenticate(reason: String) async -> Result<Void, Error> {
        let ctx = LAContext()
        ctx.localizedFallbackTitle = ""
        do {
            try await ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
