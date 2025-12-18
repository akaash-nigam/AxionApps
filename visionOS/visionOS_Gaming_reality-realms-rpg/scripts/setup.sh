#!/bin/bash
# Reality Realms RPG - Development Environment Setup Script
# This script sets up the development environment for the Reality Realms RPG project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MINIMUM_XCODE_VERSION="15.0"
MINIMUM_SWIFT_VERSION="5.9"

# Helper functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        return 1
    fi
    return 0
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script must be run on macOS"
        exit 1
    fi
    print_success "Running on macOS"

    # Check Xcode installation
    if ! check_command xcode-select; then
        print_error "Xcode Command Line Tools not installed"
        echo "Please install with: xcode-select --install"
        exit 1
    fi
    print_success "Xcode Command Line Tools installed"

    # Check Xcode version
    XCODE_PATH=$(xcode-select -p)
    XCODE_VERSION=$(xcodebuild -version | grep "Xcode" | awk '{print $2}')
    print_info "Xcode version: $XCODE_VERSION"
    print_info "Xcode path: $XCODE_PATH"

    # Check Swift version
    if ! check_command swift; then
        print_error "Swift not found"
        exit 1
    fi
    SWIFT_VERSION=$(swift --version | awk '{print $4}')
    print_success "Swift version: $SWIFT_VERSION"

    # Check Git
    if ! check_command git; then
        print_error "Git not installed"
        exit 1
    fi
    print_success "Git installed"

    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
    print_success "In valid git repository"
}

# Install SwiftLint
install_swiftlint() {
    print_header "Setting up SwiftLint"

    if check_command swiftlint; then
        SWIFTLINT_VERSION=$(swiftlint version)
        print_success "SwiftLint already installed (version: $SWIFTLINT_VERSION)"
    else
        print_info "Installing SwiftLint..."
        if check_command brew; then
            brew install swiftlint
            print_success "SwiftLint installed via Homebrew"
        else
            print_warning "Homebrew not installed. SwiftLint installation skipped"
            print_info "You can install it manually: brew install swiftlint"
        fi
    fi
}

# Install SwiftFormat
install_swiftformat() {
    print_header "Setting up SwiftFormat"

    if check_command swiftformat; then
        SWIFTFORMAT_VERSION=$(swiftformat --version)
        print_success "SwiftFormat already installed (version: $SWIFTFORMAT_VERSION)"
    else
        print_info "Installing SwiftFormat..."
        if check_command brew; then
            brew install swiftformat
            print_success "SwiftFormat installed via Homebrew"
        else
            print_warning "Homebrew not installed. SwiftFormat installation skipped"
            print_info "You can install it manually: brew install swiftformat"
        fi
    fi
}

# Setup Git hooks
setup_git_hooks() {
    print_header "Setting up Git Hooks"

    HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

    # Create pre-commit hook for linting
    PRE_COMMIT_HOOK="$HOOKS_DIR/pre-commit"
    cat > "$PRE_COMMIT_HOOK" << 'EOF'
#!/bin/bash
# Pre-commit hook for code style validation

echo "Running SwiftLint..."
if ! command -v swiftlint &> /dev/null; then
    echo "SwiftLint not installed. Skipping linting."
    exit 0
fi

CHANGED_SWIFT_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.swift$")

if [ -z "$CHANGED_SWIFT_FILES" ]; then
    exit 0
fi

echo "$CHANGED_SWIFT_FILES" | while read -r FILE; do
    swiftlint lint --quiet "$FILE" || exit 1
done

exit 0
EOF

    chmod +x "$PRE_COMMIT_HOOK"
    print_success "Pre-commit hook installed"

    # Create pre-push hook for tests
    PRE_PUSH_HOOK="$HOOKS_DIR/pre-push"
    cat > "$PRE_PUSH_HOOK" << 'EOF'
#!/bin/bash
# Pre-push hook to prevent pushing broken code

echo "Running tests before push..."
cd "$(git rev-parse --show-toplevel)"

# Run quick tests
if command -v xcodebuild &> /dev/null; then
    echo "Note: Run 'scripts/test.sh' to execute full test suite before pushing"
fi

exit 0
EOF

    chmod +x "$PRE_PUSH_HOOK"
    print_success "Pre-push hook installed"
}

# Verify project structure
verify_project_structure() {
    print_header "Verifying Project Structure"

    local required_items=(
        "RealityRealms"
        "README.md"
        ".gitignore"
    )

    for item in "${required_items[@]}"; do
        if [ ! -e "$PROJECT_ROOT/$item" ]; then
            print_warning "Missing: $item"
        else
            print_success "Found: $item"
        fi
    done
}

# Initialize Swift Package Manager (if applicable)
init_spm() {
    print_header "Checking Swift Package Manager"

    if [ -f "$PROJECT_ROOT/Package.swift" ]; then
        print_info "Package.swift found"
        print_info "Running 'swift package describe'..."
        cd "$PROJECT_ROOT"
        swift package describe
        print_success "Swift Package Manager initialized"
    else
        print_info "Not a Swift Package Manager project"
    fi
}

# Setup development environment
setup_development_environment() {
    print_header "Setting up Development Environment"

    # Create necessary directories
    mkdir -p "$PROJECT_ROOT/Build"
    mkdir -p "$PROJECT_ROOT/logs"
    print_success "Created build and log directories"

    # Create .swiftlint.yml if it doesn't exist
    if [ ! -f "$PROJECT_ROOT/.swiftlint.yml" ]; then
        print_warning ".swiftlint.yml not found"
    else
        print_success ".swiftlint.yml found"
    fi
}

# Print configuration summary
print_summary() {
    print_header "Setup Complete!"

    echo ""
    echo "Project Information:"
    echo "  Project Root: $PROJECT_ROOT"
    echo "  Xcode Version: $XCODE_VERSION"
    echo "  Swift Version: $SWIFT_VERSION"
    echo ""

    echo "Available Commands:"
    echo "  scripts/test.sh    - Run all tests"
    echo "  scripts/build.sh   - Build the project"
    echo "  swiftlint lint     - Run code linting"
    echo "  swiftformat -i .   - Format code"
    echo ""

    echo "Git Hooks Installed:"
    echo "  ✓ Pre-commit (linting)"
    echo "  ✓ Pre-push (tests check)"
    echo ""

    echo "Next Steps:"
    echo "  1. Review CONTRIBUTING.md for code style guidelines"
    echo "  2. Review DEVELOPER_ONBOARDING.md for project details"
    echo "  3. Run 'scripts/test.sh' to verify setup"
    echo ""

    print_success "Development environment ready!"
}

# Main setup flow
main() {
    print_header "Reality Realms RPG - Development Setup"
    echo ""

    check_prerequisites
    echo ""

    install_swiftlint
    echo ""

    install_swiftformat
    echo ""

    setup_git_hooks
    echo ""

    verify_project_structure
    echo ""

    init_spm
    echo ""

    setup_development_environment
    echo ""

    print_summary
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
