# Extension Creation Script Usage Guide

## Overview

The `create-paranext-extension.sh` script automates the entire process of creating a new Paranext extension from the template. It handles all the tedious file renaming, content updating, and initial setup steps.

**Key Features:**
- ✅ **Version Targeting:** Automatically sets up Platform.Bible core v0.4.0 (stable release)
- ✅ **Complete Automation:** Handles prerequisite checking, paranext-core setup, and extension creation
- ✅ **Smart Dependencies:** Installs and builds paranext-core if needed
- ✅ **Version Safety:** Ensures you're developing against stable APIs, not unstable `main` branch
- ✅ **Git Best Practices:** Keeps template history and configures remotes for easy future updates
- ✅ **Comprehensive Testing:** 92 automated tests covering all functionality

## Testing

The tool includes a comprehensive test suite. To run tests:

```bash
# Run all tests (92 tests total)
./tests/test-runner.sh

# Run specific test suite
./tests/test-runner.sh --suite unit           # 25 tests
./tests/test-runner.sh --suite integration   # 11 tests
./tests/test-runner.sh --suite error-handling # 25 tests
./tests/test-runner.sh --suite validation    # 31 tests

# Verbose output with detailed test information
./tests/test-runner.sh --verbose

# List all tests without running them
./tests/test-runner.sh --dry-run
```

See [tests/README.md](../tests/README.md) for complete test documentation including:
- Test categories and descriptions
- Individual test listings
- Test output formats
- Adding new tests

## Quick Start

### 1. Make the script executable (one time only)
```bash
chmod +x create-paranext-extension.sh
```

### 2. Run the script
```bash
# Interactive mode (recommended for beginners)
./create-paranext-extension.sh

# Or from any directory (using absolute path)
bash /home/ben/Documents/dev/ptx/create-paranext-extension.sh
```

**What happens automatically:**
1. ✅ Checks prerequisites (Node.js, Git, .NET SDK)
2. ✅ Sets up paranext-core repository with v0.4.0
3. ✅ Installs dependencies and builds paranext-core
4. ✅ Creates your extension from template
5. ✅ Updates all files with your extension details
6. ✅ Tests the build to ensure everything works

## Usage Modes

### Interactive Mode (Recommended)
```bash
./create-paranext-extension.sh
```
The script will prompt you for all required information:
- Extension name
- Author name  
- Publisher name
- Description
- Workspace directory

### Command Line Mode
```bash
./create-paranext-extension.sh \
  --name "Scripture Memory Helper" \
  --author "John Doe" \
  --publisher "myPublisher" \
  --description "Helps users memorize Bible verses" \
  --workspace ~/Documents/dev/ptx
```

### Semi-Automated Mode
```bash
# Provide some info, script will ask for the rest
./create-paranext-extension.sh --name "My Extension" --author "Your Name"
```

## Command Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `-h, --help` | Show help message | `--help` |
| `-n, --name` | Extension name | `--name "Bible Helper"` |
| `-a, --author` | Author name | `--author "John Doe"` |
| `-p, --publisher` | Publisher name | `--publisher "myCompany"` |
| `-d, --description` | Extension description | `--description "Helps with Bible study"` |
| `-w, --workspace` | Workspace directory | `--workspace ~/dev/extensions` |
| `-v, --version` | Platform.Bible version | `--version v0.5.0` |
| `-t, --template` | Template type: basic or multi | `--template multi` |
| `--skip-deps` | Skip npm install | `--skip-deps` |
| `--skip-git` | Skip git remote setup | `--skip-git` |
| `--skip-test` | Skip build test | `--skip-test` |
| `--verbose` | Show debug output | `--verbose` |

## What the Script Does

### 1. **Prerequisites Check**
- ✅ Verifies git, npm, and node are installed
- ✅ Checks Node.js version (warns if < 18)
- ✅ Looks for paranext-core in current directory
- ✅ Checks if paranext-core is on correct version (v0.4.0)

### 2. **Platform.Bible Core Setup**
- 📥 Clones paranext-core repository if not present
- 🔄 Switches to v0.4.0 stable release (not unstable `main`)
- 📦 Installs dependencies automatically
- 🔨 Builds paranext-core if needed
- ✅ Ensures stable development environment

### 3. **Name Generation**
- 📝 Converts your extension name to all required formats:
  - **Kebab-case**: `scripture-memory-helper` (files/folders)
  - **CamelCase**: `scriptureMemoryHelper` (JS/TS identifiers)  
  - **PascalCase**: `ScriptureMemoryHelper` (components/classes)

### 4. **Template Setup**
- 📂 Clones the official extension template
- 🗂️ Creates a new directory with your extension name
- 🔄 Keeps git history and sets up remotes:
  - Renames `origin` → `template` (for future updates)
  - Creates new `origin` remote (placeholder for your repo)

### 5. **File Operations**
- 📄 Renames `paranext-extension-template.d.ts` → `your-extension-name.d.ts`
- ✏️ Updates all references in:
  - `package.json`
  - `manifest.json`
  - `src/types/your-extension-name.d.ts`
  - `src/main.ts`
  - `README.md`
  - `assets/displayData.json`

### 6. **Dependency Management**
- 📦 Removes old `package-lock.json`
- 🔄 Runs `npm install` to generate new lock file
- ✅ Installs all required dependencies
- 💬 Prompts to update browserslist-db (interactive mode only, optional)

### 7. **Quality Assurance**
- 🏗️ Tests that the extension builds successfully
- 📝 Creates initial git commit with version information
- 🎯 Verifies everything is working

### 8. **Version Safety**
- 🎯 Targets Platform.Bible v0.4.0 (stable release)
- 📋 Documents target version in commit message
- ⚠️ Avoids unstable `main` branch development
- 🔒 Ensures API compatibility with released version

### 9. **Git Remote Configuration**
- 🔄 Renames template's `origin` remote to `template`
- 📌 Creates new `origin` remote (placeholder: `YOUR_REPO_URL_HERE`)
- 📜 Preserves git history for traceability
- 🔄 Enables easy template updates in the future:
  ```bash
  # Update your extension with latest template changes
  git fetch template
  git merge template/main --allow-unrelated-histories
  ```
- 💡 Remember to update `origin` URL when you create your repo:
  ```bash
  git remote set-url origin https://github.com/yourname/your-extension.git
  ```

## Example Usage Scenarios

### Creating a Bible Study Extension
```bash
./create-paranext-extension.sh \
  --name "Advanced Bible Study Tools" \
  --author "Bible Study Team" \
  --publisher "faithTech" \
  --description "Advanced tools for in-depth Bible study and analysis"
```

**Generated names:**
- Kebab: `advanced-bible-study-tools`
- Camel: `advancedBibleStudyTools`
- Pascal: `AdvancedBibleStudyTools`

**What happens:**
1. ✅ Sets up paranext-core v0.4.0 if needed
2. ✅ Creates extension targeting stable APIs
3. ✅ Ready for development against released version

### Creating a Translation Helper
```bash
./create-paranext-extension.sh \
  --name "Translation Assistant" \
  --author "SIL International" \
  --description "Assists translators with contextual suggestions"
```

### Quick Development Setup
```bash
# For rapid prototyping, skip time-consuming steps
./create-paranext-extension.sh \
  --name "Quick Prototype" \
  --skip-deps \
  --skip-test
```

## Script Output

The script provides colorful, informative output:

```
🚀 Paranext Extension Creator
==================================================

ℹ️  Checking prerequisites...
✅ All prerequisites met!

ℹ️  Please provide the following information:
📝 Enter your extension name: Scripture Memory Helper

ℹ️  Generated name variations:
  📁 Kebab-case: scripture-memory-helper
  🐪 CamelCase: scriptureMemoryHelper  
  🅿️  PascalCase: ScriptureMemoryHelper

✅ Extension creation completed successfully!

Next steps:
  1. cd scripture-memory-helper
  2. npm run watch    # Start development mode
  3. npm start        # Test in Platform.Bible
```

## Troubleshooting

### Common Issues

**Running on Windows**

This is a bash script and requires a bash environment:
- ✅ **Git Bash** (Recommended): Included with [Git for Windows](https://git-scm.com/downloads)
- ✅ **WSL** (Windows Subsystem for Linux): Full Linux environment
- ❌ **PowerShell/CMD**: Not compatible (use Git Bash instead)

```bash
# In Git Bash on Windows:
cd /c/Users/YourName/Documents/dev/ptx-extension/create-paranext-extension
./create-paranext-extension.sh
```

**"Command not found"**
```bash
# Make sure you're running from the correct directory
cd /home/ben/Documents/dev/ptx
./create-paranext-extension.sh

# Or use absolute path
bash /home/ben/Documents/dev/ptx/create-paranext-extension.sh
```

**"Permission denied"**
```bash
# Make the script executable
chmod +x create-paranext-extension.sh
```

**"Directory already exists"**
- The script will ask if you want to remove the existing directory
- Choose a different name, or manually remove the directory first

**"Git not found"**
```bash
# Install git first
sudo apt install git  # Linux
brew install git       # macOS
# Windows: Download from git-scm.com (includes Git Bash)
```

**"Node.js version too old"**
```bash
# Install Volta (recommended)
curl https://get.volta.sh | bash

# Or update Node.js directly
# Visit nodejs.org for latest version
```

**"Browserslist: caniuse-lite is outdated" warning**
This is a harmless warning about browser compatibility data. You can:
- Accept the update prompt during setup (interactive mode only)
- Update manually later: `npx update-browserslist-db@latest`
- Ignore it - it won't affect extension functionality

### Debug/Verbose Mode

For troubleshooting, use the `--verbose` flag to see detailed debug information:
```bash
./create-paranext-extension.sh --verbose -n "Debug Extension"
```

**Verbose mode shows:**
- Script version and configuration
- System dependency versions (node, npm, git, curl)
- All git commands being executed (clone, checkout, commit)
- All npm commands (install, build)
- File operations and path resolutions
- API calls to GitHub (for version detection)
- Case conversion operations (kebab, camel, pascal)
- Extension metadata being applied

This is extremely helpful for:
- 🐛 Troubleshooting script failures
- 📊 Understanding what the script does
- 🔍 Debugging version or path issues
- 🏫 Learning how the automation works

**Alternative:** For even more detail, you can use bash's debug mode:
```bash
bash -x create-paranext-extension.sh --verbose
```

This shows every shell command executed, in addition to the script's verbose output.

## Advanced Usage

### Using in CI/CD Pipelines
```bash
# Non-interactive mode for automation
./create-paranext-extension.sh 
  --name "$EXTENSION_NAME" 
  --author "$AUTHOR" 
  --publisher "$PUBLISHER" 
  --description "$DESCRIPTION" 
  --workspace "$WORKSPACE" 
  --skip-deps  # Install deps separately in CI
```

### Batch Creation
```bash
# Create multiple extensions
extensions=("Bible Search" "Verse Highlighter" "Study Notes")
for ext in "${extensions[@]}"; do
  ./create-paranext-extension.sh --name "$ext" --author "Dev Team"
done
```

### Custom Workspace Structure
```bash
# Create in specific directory structure
./create-paranext-extension.sh 
  --name "Team Extension" 
  --workspace ~/projects/platform-bible/extensions
```

## Integration with IDEs

### VS Code Integration
Add to your VS Code tasks.json:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Create New Extension",
      "type": "shell",
      "command": "${workspaceFolder}/create-paranext-extension.sh",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    }
  ]
}
```

Then use Ctrl+Shift+P → "Tasks: Run Task" → "Create New Extension"

## Script Features

### ✅ **Error Handling**
- Stops on any error (`set -e`)
- Validates all prerequisites
- Checks for existing directories
- Provides helpful error messages

### ✅ **User-Friendly**
- Colorful output with emojis
- Clear progress indicators  
- Confirmation prompts for destructive actions
- Comprehensive help documentation

### ✅ **Flexible**
- Interactive or command-line modes
- Optional steps can be skipped
- Works from any directory
- Supports various workspace structures

### ✅ **Robust**
- Handles edge cases (existing directories, missing tools)
- Validates input
- Tests the final output
- Provides rollback suggestions

---

*This script saves you 10-15 minutes of manual work and eliminates common setup errors!*
