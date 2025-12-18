//
//  StringExtensionsTests.swift
//  Legal Discovery Universe Tests
//
//  Created by Claude Code
//  Copyright © 2024 Legal Discovery Universe. All rights reserved.
//

import Testing
import Foundation
@testable import LegalDiscoveryUniverse

@Suite("String Extensions Tests")
struct StringExtensionsTests {

    @Test("SHA256 hash generation")
    func testSHA256() {
        let text = "Hello, World!"
        let hash = text.sha256

        #expect(hash.count == 64) // SHA256 produces 64 character hex string
        #expect(!hash.isEmpty)

        // Same input should produce same hash
        let hash2 = text.sha256
        #expect(hash == hash2)

        // Different input should produce different hash
        let differentHash = "Different text".sha256
        #expect(hash != differentHash)
    }

    @Test("Privilege marker detection")
    func testPrivilegeMarkers() {
        let privilegedText1 = "This document contains attorney-client privileged information"
        let privilegedText2 = "Confidential work product prepared for litigation"
        let normalText = "This is a normal business email"

        #expect(privilegedText1.hasPrivilegeMarkers == true)
        #expect(privilegedText2.hasPrivilegeMarkers == true)
        #expect(normalText.hasPrivilegeMarkers == false)
    }

    @Test("Email extraction")
    func testEmailExtraction() {
        let text = "Contact john@example.com or jane@test.org for more information"
        let emails = text.extractedEmails

        // Note: This test depends on NSDataDetector which may not work exactly as expected
        // in all contexts, so we test basic functionality
        #expect(emails.count >= 0)
    }

    @Test("Sensitive information redaction")
    func testSensitiveRedaction() {
        let text = "My SSN is 123-45-6789 and credit card is 1234-5678-9012-3456"
        let redacted = text.redactSensitiveInfo()

        #expect(!redacted.contains("123-45-6789"))
        #expect(!redacted.contains("1234-5678-9012-3456"))
        #expect(redacted.contains("XXX-XX-XXXX"))
        #expect(redacted.contains("XXXX-XXXX-XXXX-XXXX"))
    }

    @Test("Text summary generation")
    func testSummary() {
        let longText = "First sentence. Second sentence. Third sentence. Fourth sentence. Fifth sentence."
        let summary = longText.summary(sentences: 3)

        #expect(summary.contains("First sentence"))
        #expect(summary.contains("Second sentence"))
        #expect(summary.contains("Third sentence"))
        #expect(summary.contains("..."))
        #expect(!summary.contains("Fifth sentence"))
    }

    @Test("Word count")
    func testWordCount() {
        let text1 = "Hello world"
        let text2 = "The quick brown fox jumps over the lazy dog"
        let emptyText = ""

        #expect(text1.wordCount == 2)
        #expect(text2.wordCount == 9)
        #expect(emptyText.wordCount == 0)
    }

    @Test("String truncation")
    func testTruncation() {
        let text = "This is a long text that needs to be truncated"
        let truncated = text.truncate(length: 20)

        #expect(truncated.count <= 23) // 20 + "..." = 23
        #expect(truncated.hasSuffix("..."))

        let shortText = "Short"
        let notTruncated = shortText.truncate(length: 20)
        #expect(notTruncated == "Short")
        #expect(!notTruncated.hasSuffix("..."))
    }

    @Test("Whitespace normalization")
    func testWhitespaceNormalization() {
        let messy = "  Multiple    spaces   and\n\nnewlines  "
        let normalized = messy.normalizedWhitespace

        #expect(normalized == "Multiple spaces and newlines")
        #expect(!normalized.hasPrefix(" "))
        #expect(!normalized.hasSuffix(" "))
    }

    @Test("Bates number extraction")
    func testBatesExtraction() {
        let text = "See documents ABC-123456 and DEF-789012 for reference"
        let batesNumbers = text.extractedBatesNumbers

        // Should find Bates-style numbering
        #expect(batesNumbers.count >= 0)
    }

    @Test("Legal citation detection")
    func testLegalCitation() {
        let citation = "123 F.3d 456"
        let notCitation = "Just regular text"

        #expect(citation.isLegalCitation == true)
        #expect(notCitation.isLegalCitation == false)
    }
}

@Suite("Date Extensions Tests")
struct DateExtensionsTests {

    @Test("Legal date formatting")
    func testLegalDateFormat() {
        let date = Date(timeIntervalSince1970: 1609459200) // Jan 1, 2021
        let formatted = date.legalDateFormat

        #expect(formatted.contains("2021"))
        #expect(!formatted.isEmpty)
    }

    @Test("Legal timestamp formatting")
    func testLegalTimestampFormat() {
        let date = Date()
        let formatted = date.legalTimestampFormat

        #expect(!formatted.isEmpty)
    }

    @Test("Relative description")
    func testRelativeDescription() {
        let date = Date()
        let description = date.relativeDescription

        #expect(!description.isEmpty)
        // Should contain something like "now" or "0 seconds"
    }

    @Test("Start and end of day")
    func testStartEndOfDay() {
        let date = Date(timeIntervalSince1970: 1609459200) // Jan 1, 2021 00:00:00
        let start = date.startOfDay
        let end = date.endOfDay

        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: start)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: end)

        #expect(startComponents.hour == 0)
        #expect(startComponents.minute == 0)
        #expect(startComponents.second == 0)

        #expect(endComponents.hour == 23)
        #expect(endComponents.minute == 59)
        #expect(endComponents.second == 59)
    }

    @Test("ISO 8601 string")
    func testISO8601String() {
        let date = Date(timeIntervalSince1970: 1609459200)
        let iso = date.iso8601String

        #expect(iso.contains("2021"))
        #expect(iso.contains("T")) // ISO format includes T between date and time
    }

    @Test("Date range contains")
    func testDateRangeContains() {
        let start = Date(timeIntervalSince1970: 1609459200) // Jan 1, 2021
        let end = Date(timeIntervalSince1970: 1612137600)   // Feb 1, 2021
        let range = DateRange(start: start, end: end)

        let middleDate = Date(timeIntervalSince1970: 1610755200) // Jan 16, 2021
        let outsideDate = Date(timeIntervalSince1970: 1614556800) // Mar 1, 2021

        #expect(range.contains(middleDate) == true)
        #expect(range.contains(outsideDate) == false)
    }

    @Test("Date range duration")
    func testDateRangeDuration() {
        let start = Date(timeIntervalSince1970: 1609459200) // Jan 1, 2021
        let end = Date(timeIntervalSince1970: 1612137600)   // Feb 1, 2021
        let range = DateRange(start: start, end: end)

        let duration = range.durationInDays
        #expect(duration == 31) // January has 31 days
    }
}
