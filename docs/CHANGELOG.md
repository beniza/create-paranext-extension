# Changelog

All notable changes to the create-paranext-extension tool will be documented in this file.

## [2.0.0] - 2026-02-11

### 🎉 Major Release - Complete Overhaul

This release addresses all identified issues and implements best practices from the Paranext team.

### Added

- **Dynamic Version Detection**: Automatically fetches and uses the latest stable Platform.Bible release from GitHub API
- **Multi-Template Support**: Choose between basic (single extension) or multi-extension templates
- **Safety Checks**: Warns users if existing extensions might be affected by paranext-core updates
- **Template Remote Setup**: Follows Paranext team's recommended practice of setting up template as git remote for easy future updates
- **Smart paranext-core Handling**: Detects existing paranext-core and updates it instead of re-cloning
- **Version Selection**: Interactive prompt to choose latest or specific Platform.Bible version
- **Extension Template Choice**: Interactive selection between basic and multi-extension templates
- **Improved Help Text**: Comprehensive --help with examples and feature descriptions
- **Comprehensive FAQ**: Added FAQ section to README addressing common questions
- **Test Suite**: Comprehensive automated testing with 99 tests covering:
  - 27 unit tests (name conversion, version detection, file operations)
  - 11 integration tests (end-to-end workflows, git operations)
  - 28 error handling tests (prerequisites, invalid input, recovery)
  - 33 validation tests (input formats, output correctness)

### Changed

- **Git Workflow**: No longer deletes .git directory; instead sets up template remote (recommended practice)
- **Version Targeting**: Changed from hard-coded v0.4.0 to dynamic latest version detection (currently v0.5.0)
- **paranext-core Setup**: Now checks if paranext-core exists and updates it rather than always cloning
- **User Prompts**: Enhanced interactive mode with template type and version selection
- **Documentation**: Completely revised README.md with new features and best practices
- **Script Version**: Bumped to v2.0 to reflect major changes

### Fixed

- **Issue #1**: Hard-coded coupling to v0.4.0 - now dynamically fetches latest stable release
- **Issue #1a**: Added warning system when existing extensions are detected before paranext-core update
- **Issue #1b**: Script now updates existing paranext-core clone instead of attempting another clone
- **Issue #2**: Added support for both basic and multi-extension templates
- **Issue #2a**: Changed to follow Paranext team's recommended practice of keeping git history and setting up template remote

### Technical Details

#### New Functions
- `get_latest_paranext_version()`: Fetches latest release from GitHub API
- `check_existing_extensions()`: Scans workspace for existing extension projects

#### Modified Functions
- `check_prerequisites()`: Added curl requirement, improved version checking
- `setup_paranext_core()`: Now accepts target version parameter, handles existing clones, warns about existing extensions
- `get_user_input()`: Added template type and version selection prompts
- `setup_template()`: Supports both template types, sets up template remote
- `create_git_commit()`: Updated commit message with template type and version info
- `show_completion()`: Enhanced with template update instructions
- `show_help()`: Comprehensive help with all new options

#### New Command-Line Options
- `-v, --version VERSION`: Specify Platform.Bible version (default: latest)
- `-t, --template TYPE`: Choose 'basic' or 'multi' template (default: basic)

### Migration Guide

If you have existing extensions created with v1.0:

1. The new version won't affect your existing extensions
2. To adopt the new template update workflow:
   ```bash
   cd your-extension
   git remote add template https://github.com/paranext/paranext-extension-template.git
   ```
3. You can now update from the template:
   ```bash
   git fetch template
   git merge template/main --allow-unrelated-histories
   ```

### References

- [paranext-core latest release](https://github.com/paranext/paranext-core/releases/latest) - v0.5.0
- [paranext-extension-template](https://github.com/paranext/paranext-extension-template) - Basic template
- [paranext-multi-extension-template](https://github.com/paranext/paranext-multi-extension-template) - Multi template
- [Merging Template Changes](https://github.com/paranext/paranext-extension-template/wiki/Merging-Template-Changes-into-Your-Extension) - Official guide

## [1.0.0] - Initial Release

### Added
- Initial automated extension creation script
- Hard-coded support for Platform.Bible v0.4.0
- Basic extension template support
- Automatic dependency installation
- Welcome webview generation
- Extension symlink creation

### Known Issues (Addressed in v2.0)
- Hard-coded to v0.4.0
- No support for multi-extension template
- Deletes .git directory (not recommended practice)
- No warning when existing extensions present
- Always clones paranext-core even if it exists
