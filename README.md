# Create Paranext Extension (CPE)

**Automated tool for creating Platform.Bible extensions**

Reduces extension setup from ~30 manual steps to a single command, handling everything from environment validation to git workflow configuration.

---

## 📋 Repository Overview

| Component | Description |
|-----------|-------------|
| **Tool** | [create-paranext-extension.sh](create-paranext-extension.sh) |
| **Version** | 2.0.0 |
| **Status** | Production-ready |
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

For detailed usage instructions, see [Quick Start Guide](docs/QUICK_START.md).

---

## 📚 Documentation

### Getting Started
- **[Quick Start Guide](docs/QUICK_START.md)** - TL;DR examples and common scenarios
- **[Script Usage Guide](docs/script-usage-guide.md)** - Command-line options and detailed usage

### Understanding CPE
- **[CPE Specification](docs/CPE-SPEC.md)** - Single source of truth for the tool (human and machine-readable)
- **[Design Rationale](docs/CPE-DESIGN-RATIONALE.md)** - Why CPE exists and how it addresses the 30-step setup challenge
- **[Changelog](docs/CHANGELOG.md)** - Version history and changes

### Reference Guides
- **[Manual Extension Setup](docs/paranext-extension-creation-prompt.md)** - Step-by-step manual process (for reference)
- **[Workspace Setup Guide](docs/workspace-setup-guide.md)** - Platform.Bible development environment setup
- **[Update Summary](docs/UPDATE_SUMMARY.md)** - Detailed v2.0 improvements

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| **Dynamic Versioning** | Auto-detects latest stable Platform.Bible release or targets specific versions |
| **Multi-Template Support** | Choose between basic (single) or multi-extension project structures |
| **Safety Checks** | Warns about existing extensions before updating paranext-core |
| **Smart Management** | Reuses existing paranext-core instead of re-cloning |
| **Best Practices** | Follows Paranext team recommendations (keeps git history, sets up template remote) |
| **Full Automation** | Handles naming, file updates, dependencies, symlinking, and build verification |

---

## 📦 What You Get

A complete, ready-to-develop extension with:
- TypeScript + React setup
- Tailwind CSS styling
- Proper project structure
- Git workflow configured for template updates
- Built and symlinked to Platform.Bible
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

See [Prerequisites](docs/CPE-SPEC.md#prerequisites) for details.

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

See [Usage Guide](docs/script-usage-guide.md) for all options.

---

## 🗺️ Repository Structure

```
create-paranext-extension/
├── create-paranext-extension.sh   # Main automation script
├── README.md                       # This file (repository overview)
└── docs/
    ├── QUICK_START.md              # Fast getting-started guide
    ├── CPE-SPEC.md                 # Complete specification
    ├── CPE-DESIGN-RATIONALE.md     # Why CPE exists
    ├── CHANGELOG.md                # Version history
    ├── UPDATE_SUMMARY.md           # v2.0 detailed changes
    ├── script-usage-guide.md       # Detailed usage instructions
    ├── workspace-setup-guide.md    # Environment setup
    └── paranext-extension-creation-prompt.md  # Manual process reference
```

---

## 🎯 Project Goals

1. **Simplify Extension Development** - Remove setup friction, enable focus on functionality
2. **Encode Best Practices** - Apply Paranext team recommendations automatically
3. **Support Multiple Workflows** - Interactive exploration or automated CI/CD
4. **Enable Future Implementations** - Specification supports Python, Node.js, etc.

See [Design Philosophy](docs/CPE-SPEC.md#design-philosophy) for details.

---

## 🔄 Version Information

**Current Version:** 2.0.0 (February 2026)

Major improvements in v2.0:
- Dynamic version detection via GitHub API
- Multi-template support (basic/multi)
- Existing extension safety checks
- Smart paranext-core management
- Template remote setup for updates

See [Changelog](docs/CHANGELOG.md) for complete history.

---

## 🤝 Contributing

Contributions welcome! Areas of interest:
- Bug reports and feature requests
- Documentation improvements
- Multi-language implementations (Python, Node.js)
- Additional templates and customizations

See [CPE Specification](docs/CPE-SPEC.md) for implementation guidance.

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

**Quick Links:** [Quick Start](docs/QUICK_START.md) • [Specification](docs/CPE-SPEC.md) • [Design Rationale](docs/CPE-DESIGN-RATIONALE.md) • [Changelog](docs/CHANGELOG.md)
