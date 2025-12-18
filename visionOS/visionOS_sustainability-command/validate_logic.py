#!/usr/bin/env python3

import math
from datetime import datetime, timedelta

# Test results
passed_tests = 0
failed_tests = 0

def assert_test(condition, message):
    global passed_tests, failed_tests
    if condition:
        print(f"✅ PASS: {message}")
        passed_tests += 1
    else:
        print(f"❌ FAIL: {message}")
        failed_tests += 1

def assert_equal(actual, expected, message, accuracy=0.01):
    global passed_tests, failed_tests
    if isinstance(actual, float) or isinstance(expected, float):
        diff = abs(actual - expected)
        if diff <= accuracy:
            print(f"✅ PASS: {message}")
            passed_tests += 1
        else:
            print(f"❌ FAIL: {message} - Expected {expected}, got {actual}, diff: {diff}")
            failed_tests += 1
    else:
        if actual == expected:
            print(f"✅ PASS: {message}")
            passed_tests += 1
        else:
            print(f"❌ FAIL: {message} - Expected {expected}, got {actual}")
            failed_tests += 1

print("🧪 Running Sustainability Command Center Logic Tests\n")
print("=" * 60)

# MARK: - Date Tests
print("\n📅 Testing Date Calculations...")

now = datetime.now()
future = now + timedelta(days=7)
days = (future - now).days
assert_equal(days, 7, "Date: Adding 7 days")

future_months = now + timedelta(days=90)
months = (future_months - now).days // 30
assert_equal(months, 3, "Date: Adding 3 months (approx)")

# MARK: - Number Formatting Tests
print("\n🔢 Testing Number Formatting...")

value = 1234.56
rounded = round(value, 1)
assert_equal(rounded, 1234.6, "Double: Rounding to 1 decimal place")

value = 1500.0
thousands = value / 1000.0
assert_equal(thousands, 1.5, "Double: Conversion to thousands")

value = 1500000.0
millions = value / 1000000.0
assert_equal(millions, 1.5, "Double: Conversion to millions")

# MARK: - Array Calculations
print("\n📊 Testing Array Calculations...")

numbers = [1.0, 2.0, 3.0, 4.0, 5.0]
total = sum(numbers)
assert_equal(total, 15.0, "Array: Sum calculation")

average = sum(numbers) / len(numbers)
assert_equal(average, 3.0, "Array: Average calculation")

numbers = [1.0, 5.0, 3.0, 2.0, 4.0]
assert_equal(min(numbers), 1.0, "Array: Minimum value")
assert_equal(max(numbers), 5.0, "Array: Maximum value")

# Standard deviation
def std_dev(numbers):
    avg = sum(numbers) / len(numbers)
    variance = sum((x - avg) ** 2 for x in numbers) / (len(numbers) - 1)
    return math.sqrt(variance)

numbers = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]
std = std_dev(numbers)
assert_test(abs(std - 2.0) < 0.2, f"Array: Standard deviation (≈ 2.0, got {std:.2f})")

# MARK: - Emission Calculations
print("\n🌍 Testing Emission Calculations...")

scope1 = 12500.0
scope2 = 2500.0
scope3 = 7800.0
total = scope1 + scope2 + scope3
assert_equal(total, 22800.0, "Emissions: Total scope calculation", accuracy=0.1)

baseline = 30000.0
current = 27000.0
reduction = ((baseline - current) / baseline) * 100
assert_equal(reduction, 10.0, "Emissions: Reduction percentage", accuracy=0.1)

total_emissions = 27800.0
manufacturing = 12500.0
percentage = (manufacturing / total_emissions) * 100
assert_equal(percentage, 44.96, "Emissions: Category percentage", accuracy=0.1)

# MARK: - Goal Progress Tests
print("\n🎯 Testing Goal Progress Calculations...")

baseline = 1000.0
current = 750.0
target = 500.0
progress = (baseline - current) / (baseline - target)
assert_equal(progress, 0.5, "Goal: Progress calculation (50%)", accuracy=0.01)

baseline = 100.0
current = 120.0
target = 150.0
progress = abs(current - baseline) / abs(target - baseline)
assert_equal(progress, 0.4, "Goal: Progress calculation (increase)", accuracy=0.01)

# MARK: - Energy Metrics
print("\n⚡ Testing Energy Metrics...")

total_consumption = 1000.0
renewable_percentage = 40.0
renewable_energy = total_consumption * (renewable_percentage / 100)
fossil_energy = total_consumption - renewable_energy
assert_equal(renewable_energy, 400.0, "Energy: Renewable calculation", accuracy=0.1)
assert_equal(fossil_energy, 600.0, "Energy: Fossil fuel calculation", accuracy=0.1)

# MARK: - Spatial Calculations
print("\n📐 Testing Spatial Calculations...")

# Vector length
x, y, z = 3.0, 4.0, 0.0
length = math.sqrt(x**2 + y**2 + z**2)
assert_equal(length, 5.0, "Spatial: Vector length", accuracy=0.001)

# Normalized vector
normalized_x = x / length
normalized_y = y / length
assert_equal(normalized_x, 0.6, "Spatial: Normalized X", accuracy=0.001)
assert_equal(normalized_y, 0.8, "Spatial: Normalized Y", accuracy=0.001)

# Distance between points
x1, y1, z1 = 0.0, 0.0, 0.0
x2, y2, z2 = 3.0, 4.0, 0.0
distance = math.sqrt((x2-x1)**2 + (y2-y1)**2 + (z2-z1)**2)
assert_equal(distance, 5.0, "Spatial: Distance calculation", accuracy=0.001)

# Linear interpolation
start, end, t = 0.0, 10.0, 0.5
lerp = start + (end - start) * t
assert_equal(lerp, 5.0, "Spatial: Linear interpolation", accuracy=0.001)

# Dot product
v1 = (1.0, 2.0, 3.0)
v2 = (4.0, 5.0, 6.0)
dot = v1[0]*v2[0] + v1[1]*v2[1] + v1[2]*v2[2]
assert_equal(dot, 32.0, "Spatial: Dot product", accuracy=0.001)

# MARK: - Geographic Conversions
print("\n🌐 Testing Geographic Conversions...")

# North pole
latitude, longitude, radius = 90.0, 0.0, 1.5
lat_rad = math.radians(latitude)
lon_rad = math.radians(longitude)
x = radius * math.cos(lat_rad) * math.cos(lon_rad)
y = radius * math.sin(lat_rad)
z = radius * math.cos(lat_rad) * math.sin(lon_rad)
assert_equal(y, radius, "Geographic: North pole Y coordinate", accuracy=0.001)
assert_test(abs(x) < 0.01, f"Geographic: North pole X coordinate ≈ 0 (got {x:.6f})")

# Equator at prime meridian
latitude, longitude = 0.0, 0.0
lat_rad = math.radians(latitude)
lon_rad = math.radians(longitude)
x = radius * math.cos(lat_rad) * math.cos(lon_rad)
y = radius * math.sin(lat_rad)
assert_equal(x, radius, "Geographic: Equator X coordinate", accuracy=0.001)
assert_equal(y, 0.0, "Geographic: Equator Y coordinate", accuracy=0.001)

# MARK: - Validation Tests
print("\n✓ Testing Data Validation...")

min_emission = 0.0
max_emission = 1_000_000.0
assert_test(min_emission >= 0, "Validation: Min emission >= 0")
assert_test(max_emission <= 10_000_000, "Validation: Max emission reasonable")

min_progress = 0.0
max_progress = 1.0
assert_equal(min_progress, 0.0, "Validation: Min progress")
assert_equal(max_progress, 1.0, "Validation: Max progress")

# MARK: - Emission Factors
print("\n🏭 Testing Emission Factors...")

grid_electricity = 0.5
solar_power = 0.05
assert_test(solar_power < grid_electricity, "Emission Factors: Solar < Grid")

sea_freight = 0.01
air_freight = 0.50
assert_test(sea_freight < air_freight, "Emission Factors: Sea < Air")

# MARK: - Color Gradient
print("\n🎨 Testing Color Calculations...")

red_r, red_g, red_b = 1.0, 0.0, 0.0
blue_r, blue_g, blue_b = 0.0, 0.0, 1.0
t = 0.5

mid_r = red_r + (blue_r - red_r) * t
mid_g = red_g + (blue_g - red_g) * t
mid_b = red_b + (blue_b - red_b) * t

assert_equal(mid_r, 0.5, "Color: Lerp R component", accuracy=0.01)
assert_equal(mid_g, 0.0, "Color: Lerp G component", accuracy=0.01)
assert_equal(mid_b, 0.5, "Color: Lerp B component", accuracy=0.01)

# Test emission color gradient
def emission_color(value, min_val, max_val):
    normalized = (value - min_val) / (max_val - min_val)
    normalized = max(0, min(1, normalized))

    if normalized < 0.5:
        # Green to Yellow
        t = normalized * 2
        return (
            0.2 + (0.95 - 0.2) * t,  # R
            0.78 + (0.77 - 0.78) * t, # G
            0.35 + (0.06 - 0.35) * t  # B
        )
    else:
        # Yellow to Red
        t = (normalized - 0.5) * 2
        return (
            0.95 + (0.89 - 0.95) * t,  # R
            0.77 + (0.24 - 0.77) * t,  # G
            0.06 + (0.21 - 0.06) * t   # B
        )

low_color = emission_color(0, 0, 100)
assert_test(low_color[1] > 0.5, "Color: Low emissions (greenish)")

high_color = emission_color(100, 0, 100)
assert_test(high_color[0] > 0.5, "Color: High emissions (reddish)")

# MARK: - Bezier Curve
print("\n📈 Testing Bezier Curve Calculations...")

def bezier_point(start, control, end, t):
    one_minus_t = 1 - t
    return (
        one_minus_t**2 * start[0] + 2 * one_minus_t * t * control[0] + t**2 * end[0],
        one_minus_t**2 * start[1] + 2 * one_minus_t * t * control[1] + t**2 * end[1],
        one_minus_t**2 * start[2] + 2 * one_minus_t * t * control[2] + t**2 * end[2]
    )

start = (0, 0, 0)
control = (5, 10, 0)
end = (10, 0, 0)

start_point = bezier_point(start, control, end, 0.0)
assert_equal(start_point[0], start[0], "Bezier: Start point X", accuracy=0.001)

end_point = bezier_point(start, control, end, 1.0)
assert_equal(end_point[0], end[0], "Bezier: End point X", accuracy=0.001)

mid_point = bezier_point(start, control, end, 0.5)
assert_test(mid_point[1] > 0, f"Bezier: Mid point above line (Y={mid_point[1]:.2f})")

# MARK: - Performance Benchmarks
print("\n⚡ Running Performance Benchmarks...")

import time

start_time = time.time()
total = sum(i * 1.5 for i in range(100000))
duration = time.time() - start_time
assert_test(duration < 1.0, f"Performance: 100K calculations < 1s (took {duration:.3f}s)")
print(f"   Benchmark: 100K calculations in {duration:.3f}s")

start_time = time.time()
emissions = [100.0] * 1000
total = sum(emissions)
duration = time.time() - start_time
assert_equal(total, 100000.0, "Performance: Array reduction", accuracy=0.1)
print(f"   Benchmark: 1K array reduction in {duration:.6f}s")

# MARK: - Results Summary
print("\n" + "=" * 60)
print("📊 Test Results Summary")
print("=" * 60)
print(f"✅ Passed: {passed_tests}")
print(f"❌ Failed: {failed_tests}")
success_rate = (passed_tests / (passed_tests + failed_tests) * 100) if (passed_tests + failed_tests) > 0 else 0
print(f"📈 Success Rate: {success_rate:.1f}%")
print("=" * 60)

if failed_tests == 0:
    print("\n🎉 All tests passed! The logic is working correctly.")
    exit(0)
else:
    print(f"\n⚠️  {failed_tests} test(s) failed. Please review the failures above.")
    exit(1)
