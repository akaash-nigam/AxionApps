import Foundation

/// Errors related to data validation
public enum ValidationError: LocalizedError {

    case required(field: String)
    case tooShort(field: String, minimum: Int)
    case tooLong(field: String, maximum: Int)
    case outOfRange(field: String, value: Any, min: Any, max: Any)
    case invalidFormat(field: String, expected: String)
    case invalidEmail(email: String)
    case invalidURL(url: String)
    case invalidUUID(uuid: String)
    case mustBePositive(field: String, value: Double)
    case mustBeNonNegative(field: String, value: Double)
    case duplicate(field: String, value: String)
    case notFound(item: String, id: String)
    case relationshipViolation(reason: String)
    case constraintViolation(constraint: String)

    public var errorDescription: String? {
        switch self {
        case .required(let field):
            return "\(field) is required"
        case .tooShort(let field, let min):
            return "\(field) must be at least \(min) characters"
        case .tooLong(let field, let max):
            return "\(field) must be no more than \(max) characters"
        case .outOfRange(let field, let value, let min, let max):
            return "\(field) value \(value) is out of range (\(min) - \(max))"
        case .invalidFormat(let field, let expected):
            return "\(field) has invalid format (expected: \(expected))"
        case .invalidEmail(let email):
            return "Invalid email address: \(email)"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .invalidUUID(let uuid):
            return "Invalid UUID: \(uuid)"
        case .mustBePositive(let field, let value):
            return "\(field) must be positive (got: \(value))"
        case .mustBeNonNegative(let field, let value):
            return "\(field) cannot be negative (got: \(value))"
        case .duplicate(let field, let value):
            return "Duplicate \(field): \(value)"
        case .notFound(let item, let id):
            return "\(item) not found: \(id)"
        case .relationshipViolation(let reason):
            return "Relationship violation: \(reason)"
        case .constraintViolation(let constraint):
            return "Constraint violation: \(constraint)"
        }
    }
}
