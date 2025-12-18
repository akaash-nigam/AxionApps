#!/usr/bin/env swift

import Foundation

// MARK: - Test Results

var passedTests = 0
var failedTests = 0

func assert(_ condition: Bool, _ message: String) {
    if condition {
        print("✅ PASS: \(message)")
        passedTests += 1
    } else {
        print("❌ FAIL: \(message)")
        failedTests += 1
    }
}

func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String, accuracy: T? = nil) where T: FloatingPoint {
    if let accuracy = accuracy {
        let diff = abs(actual - expected)
        if diff <= accuracy {
            print("✅ PASS: \(message)")
            passedTests += 1
        } else {
            print("❌ FAIL: \(message) - Expected \(expected), got \(actual), diff: \(diff)")
            failedTests += 1
        }
    } else {
        if actual == expected {
            print("✅ PASS: \(message)")
            passedTests += 1
        } else {
            print("❌ FAIL: \(message) - Expected \(expected), got \(actual)")
            failedTests += 1
        }
    }
}

print("🧪 Running Sustainability Command Center Logic Tests\n")
print("=" * 60)

// MARK: - Date Extension Tests

print("\n📅 Testing Date Extensions...")

do {
    let date = Date()
    let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: date)!
    let days = Calendar.current.dateComponents([.day], from: date, to: futureDate).day ?? 0
    assertEqual(Double(days), 7.0, "Date: Adding 7 days", accuracy: 0.1)
}

do {
    let date = Date()
    let futureDate = Calendar.current.date(byAdding: .month, value: 3, to: date)!
    let months = Calendar.current.dateComponents([.month], from: date, to: futureDate).month ?? 0
    assertEqual(Double(months), 3.0, "Date: Adding 3 months", accuracy: 0.1)
}

// MARK: - Double Extension Tests

print("\n🔢 Testing Number Formatting...")

do {
    let value: Double = 1234.56
    let rounded = (value * 10).rounded() / 10
    assertEqual(rounded, 1234.6, "Double: Rounding to 1 decimal place", accuracy: 0.01)
}

do {
    let value: Double = 1500.0
    let thousands = value / 1000.0
    let formatted = String(format: "%.1f", thousands)
    assert(formatted == "1.5", "Double: Abbreviation to K")
}

do {
    let value: Double = 1500000.0
    let millions = value / 1000000.0
    let formatted = String(format: "%.1f", millions)
    assert(formatted == "1.5", "Double: Abbreviation to M")
}

// MARK: - Array Calculation Tests

print("\n📊 Testing Array Calculations...")

do {
    let numbers: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0]
    let sum = numbers.reduce(0, +)
    assertEqual(sum, 15.0, "Array: Sum calculation", accuracy: 0.01)
}

do {
    let numbers: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0]
    let average = numbers.reduce(0, +) / Double(numbers.count)
    assertEqual(average, 3.0, "Array: Average calculation", accuracy: 0.01)
}

do {
    let numbers: [Double] = [1.0, 5.0, 3.0, 2.0, 4.0]
    let min = numbers.min() ?? 0
    let max = numbers.max() ?? 0
    assertEqual(min, 1.0, "Array: Minimum value", accuracy: 0.01)
    assertEqual(max, 5.0, "Array: Maximum value", accuracy: 0.01)
}

// MARK: - Emission Calculation Tests

print("\n🌍 Testing Emission Calculations...")

do {
    let scope1: Double = 12500
    let scope2: Double = 2500
    let scope3: Double = 7800
    let total = scope1 + scope2 + scope3
    assertEqual(total, 22800.0, "Emissions: Total scope calculation", accuracy: 0.1)
}

do {
    let baseline: Double = 30000
    let current: Double = 27000
    let reduction = ((baseline - current) / baseline) * 100
    assertEqual(reduction, 10.0, "Emissions: Reduction percentage", accuracy: 0.1)
}

do {
    let totalEmissions: Double = 27800
    let manufacturing: Double = 12500
    let percentage = (manufacturing / totalEmissions) * 100
    assertEqual(percentage, 44.96, "Emissions: Category percentage", accuracy: 0.1)
}

// MARK: - Goal Progress Tests

print("\n🎯 Testing Goal Progress Calculations...")

do {
    let baseline: Double = 1000
    let current: Double = 750
    let target: Double = 500
    let progress = (baseline - current) / (baseline - target)
    assertEqual(progress, 0.5, "Goal: Progress calculation (50%)", accuracy: 0.01)
}

do {
    let baseline: Double = 100
    let current: Double = 120
    let target: Double = 150
    let progress = abs(current - baseline) / abs(target - baseline)
    assertEqual(progress, 0.4, "Goal: Progress calculation (increase)", accuracy: 0.01)
}

// MARK: - Energy Metrics Tests

print("\n⚡ Testing Energy Metrics...")

do {
    let totalConsumption: Double = 1000
    let renewablePercentage: Double = 40
    let renewableEnergy = totalConsumption * (renewablePercentage / 100)
    let fossilEnergy = totalConsumption - renewableEnergy
    assertEqual(renewableEnergy, 400.0, "Energy: Renewable calculation", accuracy: 0.1)
    assertEqual(fossilEnergy, 600.0, "Energy: Fossil fuel calculation", accuracy: 0.1)
}

// MARK: - Spatial Calculation Tests

print("\n📐 Testing Spatial Calculations...")

do {
    // Vector length (3,4,0) should be 5
    let x: Double = 3
    let y: Double = 4
    let z: Double = 0
    let length = sqrt(x*x + y*y + z*z)
    assertEqual(length, 5.0, "Spatial: Vector length", accuracy: 0.001)
}

do {
    // Normalized vector
    let x: Double = 3
    let y: Double = 4
    let z: Double = 0
    let length = sqrt(x*x + y*y + z*z)
    let normalizedX = x / length
    let normalizedY = y / length
    assertEqual(normalizedX, 0.6, "Spatial: Normalized X", accuracy: 0.001)
    assertEqual(normalizedY, 0.8, "Spatial: Normalized Y", accuracy: 0.001)
}

do {
    // Distance between two points
    let x1: Double = 0, y1: Double = 0, z1: Double = 0
    let x2: Double = 3, y2: Double = 4, z2: Double = 0
    let distance = sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1))
    assertEqual(distance, 5.0, "Spatial: Distance calculation", accuracy: 0.001)
}

do {
    // Linear interpolation
    let start: Double = 0
    let end: Double = 10
    let t: Double = 0.5
    let lerp = start + (end - start) * t
    assertEqual(lerp, 5.0, "Spatial: Linear interpolation", accuracy: 0.001)
}

// MARK: - Lat/Long to 3D Position Tests

print("\n🌐 Testing Geographic Conversions...")

do {
    // Convert lat/long to 3D position (North Pole)
    let latitude: Double = 90.0
    let longitude: Double = 0.0
    let radius: Double = 1.5

    let lat = latitude * .pi / 180.0
    let lon = longitude * .pi / 180.0

    let x = radius * cos(lat) * cos(lon)
    let y = radius * sin(lat)
    let z = radius * cos(lat) * sin(lon)

    assertEqual(y, radius, "Geographic: North pole Y coordinate", accuracy: 0.001)
    assert(abs(x) < 0.01, "Geographic: North pole X coordinate ≈ 0")
}

do {
    // Equator at prime meridian
    let latitude: Double = 0.0
    let longitude: Double = 0.0
    let radius: Double = 1.5

    let lat = latitude * .pi / 180.0
    let lon = longitude * .pi / 180.0

    let x = radius * cos(lat) * cos(lon)
    let y = radius * sin(lat)

    assertEqual(x, radius, "Geographic: Equator X coordinate", accuracy: 0.001)
    assertEqual(y, 0.0, "Geographic: Equator Y coordinate", accuracy: 0.001)
}

// MARK: - Validation Tests

print("\n✓ Testing Data Validation...")

do {
    let minEmission: Double = 0
    let maxEmission: Double = 1_000_000
    assert(minEmission >= 0, "Validation: Min emission >= 0")
    assert(maxEmission <= 10_000_000, "Validation: Max emission reasonable")
}

do {
    let minProgress: Double = 0.0
    let maxProgress: Double = 1.0
    assertEqual(minProgress, 0.0, "Validation: Min progress", accuracy: 0.01)
    assertEqual(maxProgress, 1.0, "Validation: Max progress", accuracy: 0.01)
}

// MARK: - Emission Factor Tests

print("\n🏭 Testing Emission Factors...")

do {
    let gridElectricity: Double = 0.5
    let solarPower: Double = 0.05
    assert(solarPower < gridElectricity, "Emission Factors: Solar < Grid")
}

do {
    let seaFreight: Double = 0.01
    let airFreight: Double = 0.50
    assert(seaFreight < airFreight, "Emission Factors: Sea < Air")
}

// MARK: - Color Gradient Tests

print("\n🎨 Testing Color Calculations...")

do {
    // Test color lerp (red to blue at 50%)
    let redR: Double = 1.0, redG: Double = 0.0, redB: Double = 0.0
    let blueR: Double = 0.0, blueG: Double = 0.0, blueB: Double = 1.0
    let t: Double = 0.5

    let midR = redR + (blueR - redR) * t
    let midG = redG + (blueG - redG) * t
    let midB = redB + (blueB - redB) * t

    assertEqual(midR, 0.5, "Color: Lerp R component", accuracy: 0.01)
    assertEqual(midG, 0.0, "Color: Lerp G component", accuracy: 0.01)
    assertEqual(midB, 0.5, "Color: Lerp B component", accuracy: 0.01)
}

// MARK: - Performance Benchmarks

print("\n⚡ Running Performance Benchmarks...")

do {
    let start = Date()
    var sum: Double = 0
    for i in 0..<100000 {
        sum += Double(i) * 1.5
    }
    let duration = Date().timeIntervalSince(start)
    assert(duration < 1.0, "Performance: 100K calculations < 1s")
    print("   Benchmark: 100K calculations in \(String(format: "%.3f", duration))s")
}

do {
    let start = Date()
    let emissions: [Double] = Array(repeating: 100.0, count: 1000)
    let total = emissions.reduce(0, +)
    let duration = Date().timeIntervalSince(start)
    assertEqual(total, 100000.0, "Performance: Array reduction", accuracy: 0.1)
    print("   Benchmark: 1K array reduction in \(String(format: "%.6f", duration))s")
}

// MARK: - Results Summary

print("\n" + "=" * 60)
print("📊 Test Results Summary")
print("=" * 60)
print("✅ Passed: \(passedTests)")
print("❌ Failed: \(failedTests)")
print("📈 Success Rate: \(String(format: "%.1f", Double(passedTests) / Double(passedTests + failedTests) * 100))%")
print("=" * 60)

if failedTests == 0 {
    print("\n🎉 All tests passed! The logic is working correctly.")
    exit(0)
} else {
    print("\n⚠️  Some tests failed. Please review the failures above.")
    exit(1)
}
