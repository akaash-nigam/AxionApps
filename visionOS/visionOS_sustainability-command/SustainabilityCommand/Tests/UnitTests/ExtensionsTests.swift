import XCTest
@testable import SustainabilityCommand

final class ExtensionsTests: XCTestCase {

    // MARK: - Date Extensions Tests

    func testDateStartOfDay() {
        let date = Date()
        let startOfDay = date.startOfDay

        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: startOfDay)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testDateAddingDays() {
        let date = Date()
        let futureDate = date.addingDays(7)

        let days = date.days(from: futureDate)
        XCTAssertEqual(days, 7)
    }

    func testDateAddingMonths() {
        let date = Date()
        let futureDate = date.addingMonths(3)

        let months = Calendar.current.dateComponents([.month], from: date, to: futureDate).month
        XCTAssertEqual(months, 3)
    }

    func testDateIsInCurrentWeek() {
        let today = Date()
        XCTAssertTrue(today.isInCurrentWeek)

        let twoWeeksAgo = today.addingDays(-14)
        XCTAssertFalse(twoWeeksAgo.isInCurrentWeek)
    }

    func testDateIsInCurrentMonth() {
        let today = Date()
        XCTAssertTrue(today.isInCurrentMonth)

        let twoMonthsAgo = today.addingMonths(-2)
        XCTAssertFalse(twoMonthsAgo.isInCurrentMonth)
    }

    // MARK: - Double Extensions Tests

    func testDoubleAsEmissions() {
        let value: Double = 1234.56
        let formatted = value.asEmissions

        XCTAssertTrue(formatted.contains("1,234.6"))
        XCTAssertTrue(formatted.contains("tCO2e"))
    }

    func testDoubleAsPercentage() {
        let value: Double = 45.7
        let formatted = value.asPercentage

        XCTAssertTrue(formatted.contains("45.7") || formatted.contains("46"))
        XCTAssertTrue(formatted.contains("%"))
    }

    func testDoubleAsCurrency() {
        let value: Double = 1234.56
        let formatted = value.asCurrency(code: "USD")

        XCTAssertTrue(formatted.contains("1,234.56"))
    }

    func testDoubleAbbreviated() {
        XCTAssertEqual(500.0.abbreviated, "500")
        XCTAssertTrue(1500.0.abbreviated.contains("1.5K"))
        XCTAssertTrue(1500000.0.abbreviated.contains("1.5M"))
        XCTAssertTrue(1500000000.0.abbreviated.contains("1.5B"))
    }

    func testDoubleRounded() {
        let value: Double = 1.23456789
        XCTAssertEqual(value.rounded(to: 2), 1.23)
        XCTAssertEqual(value.rounded(to: 4), 1.2346)
        XCTAssertEqual(value.rounded(to: 0), 1.0)
    }

    // MARK: - Array Extensions Tests

    func testArraySum() {
        let numbers: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0]
        XCTAssertEqual(numbers.sum, 15.0)

        let empty: [Double] = []
        XCTAssertEqual(empty.sum, 0.0)
    }

    func testArrayAverage() {
        let numbers: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0]
        XCTAssertEqual(numbers.average, 3.0)

        let empty: [Double] = []
        XCTAssertEqual(empty.average, 0.0)
    }

    func testArrayMinMax() {
        let numbers: [Double] = [1.0, 5.0, 3.0, 2.0, 4.0]
        XCTAssertEqual(numbers.minimum, 1.0)
        XCTAssertEqual(numbers.maximum, 5.0)
    }

    func testArrayStandardDeviation() {
        let numbers: [Double] = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]
        let stdDev = numbers.standardDeviation
        XCTAssertTrue(abs(stdDev - 2.0) < 0.1) // Approximately 2.0
    }

    // MARK: - String Extensions Tests

    func testStringIsValidEmail() {
        XCTAssertTrue("test@example.com".isValidEmail)
        XCTAssertTrue("user.name+tag@example.co.uk".isValidEmail)
        XCTAssertFalse("invalid@".isValidEmail)
        XCTAssertFalse("@example.com".isValidEmail)
        XCTAssertFalse("notanemail".isValidEmail)
    }

    func testStringTruncated() {
        let text = "This is a long string"
        XCTAssertEqual(text.truncated(to: 10), "This is...")
        XCTAssertEqual(text.truncated(to: 100), text)
    }

    func testStringCapitalizedFirstLetter() {
        XCTAssertEqual("hello".capitalizedFirstLetter, "Hello")
        XCTAssertEqual("HELLO".capitalizedFirstLetter, "HELLO")
        XCTAssertEqual("hELLO".capitalizedFirstLetter, "HELLO")
    }

    // MARK: - Collection Extensions Tests

    func testCollectionSafeSubscript() {
        let array = [1, 2, 3, 4, 5]
        XCTAssertEqual(array[safe: 2], 3)
        XCTAssertNil(array[safe: 10])
        XCTAssertNil(array[safe: -1])
    }

    // MARK: - Result Extensions Tests

    func testResultValue() {
        let successResult: Result<Int, Error> = .success(42)
        XCTAssertEqual(successResult.value, 42)
        XCTAssertNil(successResult.error)

        let failureResult: Result<Int, TestError> = .failure(.testError)
        XCTAssertNil(failureResult.value)
        XCTAssertNotNil(failureResult.error)
    }
}

// MARK: - Test Helpers

enum TestError: Error {
    case testError
}
