# Create Paranext Extension (CPE)

**Automated tool for creating Platform.Bible extensions**

Reduces extension setup from ~30 manual steps to a single command, handling everything from environment validation to git workflow configuration.

---

## 📋 Repository Overview

| Component | Description |
|-----------|-------------|
| **Tool** | [create-paranext-extension.sh](create-paranext-extension.sh) |
| **Version** | 2.1.0 |
| **Status** | Under evaluation - testing in progress |
| **Created** | With assistance from Claude Sonnet 4.5 |
| **Platform** | Platform.Bible Extension Development |

---

## 🚀 Quick Start

```bash
# Make executable (first time only)
chmod +x create-paranext-extension.sh

# Run interactively
./create-paranext-extension.sh
```

For detailed usage instructions, see [Quick Start Guide](docs/guides/QUICK_START.md).

---

## 📚 Documentation

### Getting Started
- **[Quick Start Guide](docs/guides/QUICK_START.md)** - TL;DR examples and common scenarios
- **[Script Usage Guide](docs/guides/USAGE.md)** - Command-line options and detailed usage
- **[Workspace Setup Guide](docs/guides/WORKSPACE_SETUP.md)** - Platform.Bible development environment setup

### Reference Documentation
- **[CPE Specification](docs/reference/SPECIFICATION.md)** - Single source of truth for the tool (human and machine-readable)
- **[Design Rationale](docs/reference/DESIGN_RATIONALE.md)** - Why CPE exists and how it addresses the 30-step setup challenge
- **[Manual Extension Setup](docs/reference/MANUAL_SETUP.md)** - Step-by-step manual process (for reference)

### Testing & Quality
- **[Test Suite](tests/README.md)** - Comprehensive test suite (92 tests covering unit, integration, error handling, and validation)

### Development
- **[Changelog](docs/development/CHANGELOG.md)** - Version history and changes
- **[Review Findings](docs/development/REVIEW_FINDINGS.md)** - Code review results and improvements
- **[Update Summary](docs/development/UPDATE_SUMMARY.md)** - Detailed v2.0 improvements

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| **Dynamic Versioning** | Auto-detects latest stable Platform.Bible release or targets specific versions |
| **Multi-Template Support** | Choose between basic (single) or multi-extension project structures |
| **Safety Checks** | Warns about existing extensions before updating paranext-core |
| **Smart Management** | Reuses existing paranext-core instead of re-cloning |
| **Best Practices** | Follows Paranext team recommendations (keeps git history, sets up template remote) |
| **Full Automation** | Handles naming, file updates, dependencies, and build verification |

---

## 📦 What You Get

A complete, ready-to-develop extension with:
- TypeScript + React setup
- Tailwind CSS styling
- Proper project structure
- Git workflow configured for template updates
- Ready to launch with Platform.Bible (via `npm start`)
- Welcome screen with next steps

See [Output Specification](docs/CPE-SPEC.md#output-specification) for complete details.

---

## 🔧 Requirements

| Software | Version | Status | Purpose |
|----------|---------|--------|---------|
| **Node.js** | 18.0+ (22.15.1+ recommended) | Required | JavaScript runtime |
| **npm** | Any | Required | Package management |
| **Git** | Any | Required | Version control |
| **curl** | Any | Recommended* | Dynamic version detection |
| **.NET SDK** | 8.0+ | Recommended | Platform.Bible core |

*Falls back to v0.5.0 if curl unavailable

### Platform Support

- **Linux/macOS**: Native bash script execution
- **Windows**: Requires [Git Bash](https://git-scm.com/downloads) (included with Git for Windows)
  - Run the script in Git Bash terminal
  - Git Bash provides a Unix-like environment on Windows

See [Prerequisites](docs/reference/SPECIFICATION.md#prerequisites) for details.

---

## 📖 Usage Examples

### Interactive Mode
```bash
./create-paranext-extension.sh
# Guided prompts for all options
```

### Command-Line Mode
```bash
# Latest version, basic template
./create-paranext-extension.sh --name "My Extension" --author "Your Name"

# Specific version, multi-extension template
./create-paranext-extension.sh --name "My Tools" --version v0.5.0 --template multi

# Fast setup (skip optional steps)
./create-paranext-extension.sh --name "Test" --skip-deps --skip-test
```

See [Usage Guide](docs/guides/USAGE.md) for all options.

---

## 🗺️ Repository Structure

```
create-paranext-extension/
├── create-paranext-extension.sh   # Main automation script
├── README.md                       # This file (repository overview)
├── docs/
│   ├── guides/                     # User guides
│   │   ├── QUICK_START.md          # Fast getting-started guide
│   │   ├── USAGE.md                # Detailed script usage
│   │   └── WORKSPACE_SETUP.md      # Environment setup
│   ├── reference/                  # Reference documentation
│   │   ├── SPECIFICATION.md        # Complete CPE specification
│   │   ├── DESIGN_RATIONALE.md     # Design decisions and philosophy
│   │   └── MANUAL_SETUP.md         # Manual process reference
│   └── development/                # Development documentation
│       ├── CHANGELOG.md            # Version history
│       ├── REVIEW_FINDINGS.md      # Code review results
│       └── UPDATE_SUMMARY.md       # Detailed v2.0 changes
└── tests/
    ├── test-runner.sh              # Main test orchestrator (92 tests)
    ├── test-helpers.sh             # Common test utilities
    ├── test-unit.sh                # Unit tests
    ├── test-integration.sh         # Integration tests
    ├── test-error-handling.sh      # Error handling tests
    ├── test-validation.sh          # Validation tests
    └── README.md                   # Test documentation
```

---

## 🎯 Project Goals

1. **Simplify Extension Development** - Remove setup friction, enable focus on functionality
2. **Encode Best Practices** - Apply Paranext team recommendations automatically
3. **Support Multiple Workflows** - Interactive exploration or automated CI/CD
4. **Enable Future Implementations** - Specification supports Python, Node.js, etc.

See [Design Philosophy](docs/reference/SPECIFICATION.md#design-philosophy) for details.

---

## 🔄 Version Information

**Current Version:** 2.1.0 (February 2026)

Major improvements in v2.0:
- Dynamic version detection via GitHub API
- Multi-template support (basic/multi)
- Existing extension safety checks
- Smart paranext-core management
- Template remote setup for updates

See [Changelog](docs/development/CHANGELOG.md) for complete history.

---

## � Testing

The project includes a comprehensive test suite with 92 tests:

```bash
# Run all tests
./tests/test-runner.sh

# Run specific test suite
./tests/test-runner.sh --suite unit
./tests/test-runner.sh --suite integration
./tests/test-runner.sh --suite error-handling
./tests/test-runner.sh --suite validation

# Verbose output
./tests/test-runner.sh --verbose
```

See [Test Suite Documentation](tests/README.md) for detailed information.

---

## 🤝 Contributing

Contributions welcome! Areas of interest:
- Bug reports and feature requests
- Documentation improvements
- Multi-language implementations (Python, Node.js)
- Additional templates and customizations
- Test coverage improvements

See [CPE Specification](docs/reference/SPECIFICATION.md) for implementation guidance.

---

## 📄 License

Follows Platform.Bible licensing.

---

## 🔗 Related Links

- [Platform.Bible Core](https://github.com/paranext/paranext-core)
- [Extension Template (Basic)](https://github.com/paranext/paranext-extension-template)
- [Extension Template (Multi)](https://github.com/paranext/paranext-multi-extension-template)
- [Platform.Bible Documentation](https://github.com/paranext/paranext-core/wiki)

---

**Quick Links:** [Quick Start](docs/guides/QUICK_START.md) • [Specification](docs/reference/SPECIFICATION.md) • [Design Rationale](docs/reference/DESIGN_RATIONALE.md) • [Changelog](docs/development/CHANGELOG.md)
