.PHONY: help build test clean lint format ci

# Default target
help:
	@echo "Holographic Board Games - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make build         - Build the project"
	@echo "  make test          - Run all tests"
	@echo "  make test-ios      - Run tests on iOS simulator"
	@echo "  make test-vision   - Run tests on visionOS simulator"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make lint          - Run SwiftLint"
	@echo "  make format        - Auto-format code with SwiftLint"
	@echo "  make ci            - Run CI checks locally"
	@echo "  make package-build - Build Swift Package"
	@echo "  make package-test  - Test Swift Package"

# Build
build:
	xcodebuild build \
		-scheme HolographicBoardGames \
		-destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO

# Test targets
test: test-vision

test-ios:
	xcodebuild clean test \
		-scheme HolographicBoardGames \
		-destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
		-enableCodeCoverage YES \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO

test-vision:
	xcodebuild clean test \
		-scheme HolographicBoardGames \
		-destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
		-enableCodeCoverage YES \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO

# Clean
clean:
	xcodebuild clean \
		-scheme HolographicBoardGames
	rm -rf .build
	rm -rf DerivedData
	rm -rf ~/Library/Developer/Xcode/DerivedData/HolographicBoardGames-*

# Linting
lint:
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint lint; \
	else \
		echo "SwiftLint not installed. Run: brew install swiftlint"; \
		exit 1; \
	fi

format:
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint --fix --format; \
	else \
		echo "SwiftLint not installed. Run: brew install swiftlint"; \
		exit 1; \
	fi

# CI checks (run locally before pushing)
ci: clean lint test

# Swift Package Manager
package-build:
	swift build -v

package-test:
	swift test -v

package-clean:
	swift package clean
	rm -rf .build

# Development helpers
install-deps:
	@echo "Installing development dependencies..."
	@if ! command -v swiftlint >/dev/null 2>&1; then \
		echo "Installing SwiftLint..."; \
		brew install swiftlint; \
	fi
	@if ! command -v xcpretty >/dev/null 2>&1; then \
		echo "Installing xcpretty..."; \
		gem install xcpretty; \
	fi
	@echo "Dependencies installed!"

# Open project
open:
	@if [ -d "HolographicBoardGames.xcodeproj" ]; then \
		open HolographicBoardGames.xcodeproj; \
	elif [ -d "HolographicBoardGames.xcworkspace" ]; then \
		open HolographicBoardGames.xcworkspace; \
	else \
		echo "No Xcode project or workspace found"; \
	fi
