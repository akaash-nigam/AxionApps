import XCTest
@testable import IndustrialCADCAM

/// Unit tests for extension classes
final class ExtensionTests: XCTestCase {

    // MARK: - Double Extension Tests

    func testDoubleFormatting() {
        let value = 123.456789

        XCTAssertEqual(value.formatted(decimalPlaces: 2), "123.46")
        XCTAssertEqual(value.formatted(decimalPlaces: 0), "123")
        XCTAssertEqual(value.formatted(withUnit: "mm", decimalPlaces: 2), "123.46 mm")
    }

    func testDoubleRounding() {
        let value = 123.456789

        XCTAssertEqual(value.rounded(toPlaces: 2), 123.46, accuracy: 0.001)
        XCTAssertEqual(value.roundedUp(toPlaces: 2), 123.46, accuracy: 0.001)
        XCTAssertEqual(value.roundedDown(toPlaces: 2), 123.45, accuracy: 0.001)
        XCTAssertEqual(value.rounded(toNearest: 10.0), 120.0, accuracy: 0.001)
    }

    func testDoubleClamping() {
        XCTAssertEqual(150.0.clamped(min: 0, max: 100), 100.0)
        XCTAssertEqual((-10.0).clamped(min: 0, max: 100), 0.0)
        XCTAssertEqual(50.0.clamped(min: 0, max: 100), 50.0)

        XCTAssertEqual(1.5.clamped01(), 1.0)
        XCTAssertEqual((-0.5).clamped01(), 0.0)
        XCTAssertEqual(0.5.clamped01(), 0.5)
    }

    func testDoubleComparison() {
        XCTAssertTrue(1.0001.isApproximatelyEqual(to: 1.0, tolerance: 0.001))
        XCTAssertFalse(1.01.isApproximatelyEqual(to: 1.0, tolerance: 0.001))

        XCTAssertTrue(5.0.isWithin(1.0...10.0))
        XCTAssertFalse(15.0.isWithin(1.0...10.0))
    }

    func testDoubleValidation() {
        XCTAssertTrue(5.0.isPositive)
        XCTAssertFalse((-5.0).isPositive)

        XCTAssertTrue((-5.0).isNegative)
        XCTAssertFalse(5.0.isNegative)

        XCTAssertTrue(0.00001.isZero(tolerance: 0.001))
        XCTAssertFalse(0.1.isZero(tolerance: 0.001))

        XCTAssertTrue(5.0.isFiniteNumber)
        XCTAssertFalse(Double.infinity.isFiniteNumber)
        XCTAssertFalse(Double.nan.isFiniteNumber)
    }

    func testDoubleInterpolation() {
        let lerp = 0.0.lerp(to: 10.0, t: 0.5)
        XCTAssertEqual(lerp, 5.0, accuracy: 0.001)

        let inverseLerp = 0.0.inverseLerp(to: 10.0, value: 5.0)
        XCTAssertEqual(inverseLerp, 0.5, accuracy: 0.001)
    }

    func testDoublePercentage() {
        let percentage = 50.0.asPercentageOf(200.0)
        XCTAssertEqual(percentage, 25.0, accuracy: 0.001)

        let change = 150.0.percentageChange(from: 100.0)
        XCTAssertEqual(change, 50.0, accuracy: 0.001)
    }

    func testDoubleDegreesRadians() {
        let radians = 180.0.degreesToRadians
        XCTAssertEqual(radians, Double.pi, accuracy: 0.0001)

        let degrees = Double.pi.radiansToDegrees
        XCTAssertEqual(degrees, 180.0, accuracy: 0.0001)
    }

    func testDoubleArrayStatistics() {
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]

        XCTAssertEqual(values.sum, 15.0, accuracy: 0.001)
        XCTAssertEqual(values.average, 3.0, accuracy: 0.001)
        XCTAssertEqual(values.minimum, 1.0)
        XCTAssertEqual(values.maximum, 5.0)
        XCTAssertEqual(values.range, 4.0)
        XCTAssertEqual(values.median, 3.0)
    }

    // MARK: - String Extension Tests

    func testStringValidation() {
        XCTAssertTrue("   ".isBlank)
        XCTAssertFalse("text".isBlank)

        XCTAssertTrue("abc".isAlphabetic)
        XCTAssertFalse("abc123".isAlphabetic)

        XCTAssertTrue("123".isNumeric)
        XCTAssertFalse("123abc".isNumeric)

        XCTAssertTrue("abc123".isAlphanumeric)
        XCTAssertFalse("abc-123".isAlphanumeric)

        XCTAssertTrue("test@example.com".isValidEmail)
        XCTAssertFalse("invalid-email".isValidEmail)

        XCTAssertTrue("https://example.com".isValidURL)

        let uuid = UUID().uuidString
        XCTAssertTrue(uuid.isValidUUID)
        XCTAssertFalse("not-a-uuid".isValidUUID)
    }

    func testStringTrimming() {
        XCTAssertEqual("  test  ".trimmed, "test")
        XCTAssertEqual("test string".withoutWhitespace, "teststring")
        XCTAssertEqual("line1\nline2".withoutNewlines, "line1line2")
    }

    func testStringCaseConversion() {
        XCTAssertEqual("hello world".titleCased, "Hello World")
        XCTAssertEqual("hello world".sentenceCased, "Hello world")
        XCTAssertEqual("camelCaseString".camelToSnakeCase, "camel_case_string")
        XCTAssertEqual("snake_case_string".snakeToCamelCase, "snakeCaseString")
    }

    func testStringSubstring() {
        let text = "Hello World"

        XCTAssertEqual(text.substring(from: 6), "World")
        XCTAssertEqual(text.substring(to: 5), "Hello")
        XCTAssertEqual(text.first(5), "Hello")
        XCTAssertEqual(text.last(5), "World")
    }

    func testStringTruncation() {
        let longText = "This is a long string"
        XCTAssertEqual(longText.truncated(to: 10), "This is...")
    }

    func testStringPadding() {
        XCTAssertEqual("test".padded(toLength: 10, withPad: "0", startingAt: .left), "000000test")
        XCTAssertEqual("test".padded(toLength: 10, withPad: "0", startingAt: .right), "test000000")
    }

    func testStringReplacement() {
        XCTAssertEqual("hello world".replacing("world", with: "swift"), "hello swift")
        XCTAssertEqual("hello world".removing("world"), "hello ")
    }

    func testStringContains() {
        XCTAssertTrue("Hello World".containsIgnoringCase("world"))
        XCTAssertEqual("hello hello hello".occurrences(of: "hello"), 3)
    }

    func testStringLinesAndWords() {
        let text = "line 1\nline 2\nline 3"
        XCTAssertEqual(text.lineCount, 3)

        let sentence = "This is a test"
        XCTAssertEqual(sentence.wordCount, 4)
    }

    func testStringConversion() {
        XCTAssertEqual("123.45".toDouble, 123.45)
        XCTAssertEqual("123".toInt, 123)
        XCTAssertEqual("true".toBool, true)
        XCTAssertEqual("false".toBool, false)
    }

    func testStringEncoding() {
        let original = "test string"
        let encoded = original.base64Encoded
        XCTAssertNotNil(encoded.base64Decoded)
        XCTAssertEqual(encoded.base64Decoded, original)
    }

    func testStringFilePath() {
        let path = "/path/to/file.txt"
        XCTAssertEqual(path.fileExtension, "txt")
        XCTAssertEqual(path.lastPathComponent, "file.txt")
    }

    func testStringSanitization() {
        let unsafe = "file:name*.txt"
        XCTAssertFalse(unsafe.sanitizedForFileName.contains(":"))
        XCTAssertFalse(unsafe.sanitizedForFileName.contains("*"))
    }

    // MARK: - Date Extension Tests

    func testDateComponents() {
        let date = Date.from(year: 2025, month: 11, day: 19, hour: 14, minute: 30, second: 0)!

        XCTAssertEqual(date.year, 2025)
        XCTAssertEqual(date.month, 11)
        XCTAssertEqual(date.day, 19)
        XCTAssertEqual(date.hour, 14)
        XCTAssertEqual(date.minute, 30)
        XCTAssertEqual(date.second, 0)
    }

    func testDateComparisons() {
        let today = Date()

        XCTAssertTrue(today.isToday)
        XCTAssertFalse(today.adding(days: 1).isToday)
        XCTAssertTrue(today.adding(days: 1).isTomorrow)
        XCTAssertTrue(today.adding(days: -1).isYesterday)
    }

    func testDateArithmetic() {
        let date = Date()

        let tomorrow = date.adding(days: 1)
        XCTAssertTrue(tomorrow.days(since: date) == 1)

        let nextHour = date.adding(hours: 1)
        XCTAssertTrue(nextHour.hours(since: date) == 1)

        let nextMinute = date.adding(minutes: 1)
        XCTAssertTrue(nextMinute.minutes(since: date) == 1)
    }

    func testDateStartOfDay() {
        let date = Date.from(year: 2025, month: 11, day: 19, hour: 14, minute: 30, second: 0)!
        let startOfDay = date.startOfDay

        XCTAssertEqual(startOfDay.hour, 0)
        XCTAssertEqual(startOfDay.minute, 0)
        XCTAssertEqual(startOfDay.second, 0)
    }

    func testDateValidation() {
        let date = Date()
        XCTAssertTrue(date.isReasonable)

        let farFuture = date.adding(years: 200)
        XCTAssertFalse(farFuture.isReasonable)
    }

    func testTimeIntervalFormatting() {
        let twoHours: TimeInterval = 2 * 60 * 60
        XCTAssertEqual(twoHours.durationString, "02:00:00")

        let twoMinutes: TimeInterval = 2 * 60
        XCTAssertEqual(twoMinutes.durationString, "02:00")
    }

    // MARK: - UUID Extension Tests

    func testUUIDShortID() {
        let uuid = UUID()
        XCTAssertEqual(uuid.shortID.count, 8)
        XCTAssertEqual(uuid.mediumID.count, 13)
    }

    func testUUIDCompact() {
        let uuid = UUID()
        let compact = uuid.compact
        XCTAssertFalse(compact.contains("-"))
        XCTAssertEqual(compact.count, 32)
    }

    func testUUIDFromCompact() {
        let original = UUID()
        let compact = original.compact
        let restored = UUID.from(compact: compact)

        XCTAssertNotNil(restored)
        XCTAssertEqual(restored?.compact, compact)
    }

    func testUUIDIsNil() {
        let nilUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        XCTAssertTrue(nilUUID.isNil)

        let normalUUID = UUID()
        XCTAssertFalse(normalUUID.isNil)
    }

    func testUUIDArrayExtensions() {
        let uuids = [UUID(), UUID(), UUID()]
        XCTAssertEqual(uuids.shortIDs.count, 3)
        XCTAssertEqual(uuids.displayStrings.count, 3)

        let sorted = uuids.sorted()
        XCTAssertEqual(sorted.count, 3)
    }

    func testOptionalUUIDExtensions() {
        let uuid: UUID? = UUID()
        XCTAssertFalse(uuid.isNilOrEmpty)

        let nilUUID: UUID? = nil
        XCTAssertTrue(nilUUID.isNilOrEmpty)

        XCTAssertEqual(nilUUID.shortIDOrPlaceholder, "--------")
        XCTAssertEqual(nilUUID.displayStringOrPlaceholder, "NO-ID")
    }
}
