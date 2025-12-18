import Foundation

enum LBSError: LocalizedError, Identifiable {
    case networkUnavailable
    case networkTimeout
    case deviceNotFound(UUID)
    case deviceUnreachable(UUID)
    case deviceCommandFailed(UUID, underlying: Error)
    case authorizationDenied
    case authenticationFailed
    case dataNotFound
    case unknown(Error)

    var id: String {
        switch self {
        case .networkUnavailable:
            return "network_unavailable"
        case .networkTimeout:
            return "network_timeout"
        case .deviceNotFound(let id):
            return "device_not_found_\(id.uuidString)"
        case .deviceUnreachable(let id):
            return "device_unreachable_\(id.uuidString)"
        case .deviceCommandFailed(let id, _):
            return "device_command_failed_\(id.uuidString)"
        case .authorizationDenied:
            return "authorization_denied"
        case .authenticationFailed:
            return "authentication_failed"
        case .dataNotFound:
            return "data_not_found"
        case .unknown(let error):
            return "unknown_\(error.localizedDescription)"
        }
    }

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network is unavailable"

        case .networkTimeout:
            return "Request timed out"

        case .deviceNotFound:
            return "Device not found"

        case .deviceUnreachable:
            return "Device is not reachable"

        case .deviceCommandFailed(_, let error):
            return "Device command failed: \(error.localizedDescription)"

        case .authorizationDenied:
            return "Authorization denied"

        case .authenticationFailed:
            return "Authentication failed"

        case .dataNotFound:
            return "Data not found"

        case .unknown(let error):
            return "An error occurred: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Check your network connection"

        case .networkTimeout:
            return "Try again later"

        case .deviceUnreachable:
            return "Make sure the device is powered on and connected"

        case .authorizationDenied:
            return "Grant permission in Settings"

        default:
            return nil
        }
    }

    var isRetryable: Bool {
        switch self {
        case .networkTimeout, .networkUnavailable, .deviceUnreachable:
            return true
        default:
            return false
        }
    }
}
