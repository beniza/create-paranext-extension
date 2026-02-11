# CPE Test Suite

Comprehensive test suite for the Create Paranext Extension (CPE) tool.

## Overview

This test suite validates all aspects of CPE functionality including:

- **Unit Tests**: Individual function logic and transformations
- **Integration Tests**: Complete end-to-end workflows
- **Error Handling Tests**: Error detection and recovery
- **Validation Tests**: Input validation and output correctness

## Quick Start

### Run All Tests

```bash
./tests/test-runner.sh
```

### Run Specific Test Suite

```bash
./tests/test-runner.sh --suite unit
./tests/test-runner.sh --suite integration
./tests/test-runner.sh --suite error-handling
./tests/test-runner.sh --suite validation
```

### Verbose Output

```bash
./tests/test-runner.sh --verbose
```

### Dry Run (List Tests Without Running)

```bash
./tests/test-runner.sh --dry-run
```

## Test Suite Structure

```
tests/
├── test-runner.sh           # Main test orchestration script
├── test-helpers.sh          # Common utilities and helpers
├── test-unit.sh             # Unit tests (25 tests)
├── test-integration.sh      # Integration tests (11 tests)
├── test-error-handling.sh   # Error handling tests (25 tests)
├── test-validation.sh       # Validation tests (31 tests)
└── README.md                # This file
```

## Test Categories

### Unit Tests (test-unit.sh)

Tests individual functions in isolation:

- **Name Conversion** (6 tests): kebab-case, camelCase, PascalCase transformations
- **Version Detection** (3 tests): Format validation, version comparison
- **Extension Detection** (4 tests): Detecting existing extensions in workspace
- **Directory Validation** (3 tests): Path validation, directory creation
- **File Operations** (3 tests): File replacement, content updates
- **Configuration Validation** (4 tests): Config file parsing and validation
- **Template Selection** (2 tests): Template type detection and application

### Integration Tests (test-integration.sh)

Tests complete end-to-end workflows:

- **Full Workflow Tests** (5 tests): Complete extension setup, multi-template, version selection
- **Git Operations** (2 tests): Remote setup, commit workflows
- **npm Operations** (1 test): Package validation
- **File Structure** (2 tests): Complete directory structure validation
- **Template Content** (1 test): Placeholder replacement verification

### Error Handling Tests (test-error-handling.sh)

Tests error scenarios and recovery:

- **Missing Prerequisites** (4 tests): git, node, npm, curl detection
- **Invalid Input** (5 tests): Empty names, invalid formats, nonexistent paths
- **Directory Conflicts** (3 tests): Existing directories, version conflicts, permissions
- **Network Errors** (3 tests): API timeouts, clone failures, invalid URLs
- **Build Errors** (3 tests): npm install/build failures, compilation errors
- **File Update Errors** (2 tests): Read-only files, corrupted JSON
- **Warnings** (3 tests): Existing extensions, old versions, beta versions
- **Recovery** (2 tests): Cleanup on error, partial setup detection

### Validation Tests (test-validation.sh)

Tests input validation and output correctness:

- **Name Format** (6 tests): Valid/invalid kebab-case, name conversions, special chars
- **Version Format** (4 tests): Valid/invalid versions, prerelease tags, v prefix
- **Path Validation** (5 tests): Absolute/relative paths, Windows paths, spaces, normalization
- **File Content** (3 tests): package.json, manifest.json, tsconfig.json structure
- **Placeholders** (3 tests): Replacement correctness, no corruption
- **Symlink Structure** (2 tests): Target correctness, link type
- **Git Configuration** (3 tests): Valid/invalid URLs, branch names
- **npm Configuration** (2 tests): Scope format, package names
- **File Permissions** (2 tests): Executable scripts, readable configs
- **Output Structure** (3 tests): Required files, directories, paranext-core structure

## Test Helpers

The `test-helpers.sh` file provides 50+ utilities:

### Environment Management

- `setup_test_env()`: Create isolated test workspace
- `cleanup_test_env()`: Remove test artifacts
- `reset_test_env()`: Clean and reinitialize environment

### Assertions

- `assert_equals <expected> <actual> <message>`
- `assert_not_equals <expected> <actual> <message>`
- `assert_contains <haystack> <needle> <message>`
- `assert_file_exists <file> <message>`
- `assert_file_not_exists <file> <message>`
- `assert_dir_exists <dir> <message>`
- `assert_command_success <command> <message>`
- `assert_command_fails <command> <message>`
- `assert_regex_match <string> <pattern> <message>`
- `assert_json_valid <file> <message>`

### Mock Functions

- `mock_git_version <version>`: Mock git version
- `mock_node_version <version>`: Mock node version
- `mock_npm_version <version>`: Mock npm version
- `mock_curl_available <true|false>`: Mock curl availability
- `mock_github_api_response <version>`: Mock API response

### Test Fixtures

- `create_mock_extension <name>`: Create mock extension structure
- `create_mock_paranext_core [version]`: Create mock paranext-core
- `create_mock_package_json <name> <version>`: Create package.json
- `create_mock_manifest_json <name>`: Create manifest.json
- `create_mock_tsconfig_json`: Create tsconfig.json

### Utilities

- `skip_test <reason>`: Skip test with explanation
- `require_command <command> [message]`: Skip if command unavailable
- `wait_for_condition <command> <timeout>`: Wait for condition
- `run_test <name> <function>`: Execute test with reporting

## Test Output

### Success Output

```
✓ Test name passed
```

### Failure Output

```
✗ Test name failed
  Expected: value1
  Actual: value2
```

### Skipped Output

```
⊘ Test name skipped: Reason for skipping
```

### Summary

```
Unit Tests: 25 passed, 2 failed

Overall: 95 passed, 5 failed
```

## Test Logs

Test runs are logged to `tests/test-logs/`:

```
test-run-YYYYMMDD-HHMMSS.log
```

Logs include:
- All test output (verbose mode)
- Error messages and stack traces
- Environment information
- Test timing and statistics

## Writing New Tests

### Test Function Template

```bash
test_my_new_test() {
    # Setup
    local input="test-value"
    local expected="expected-result"
    
    # Execute
    local actual=$(my_function "$input")
    
    # Assert
    assert_equals "$expected" "$actual" "Should produce correct output"
}
```

### Register Test

Add to test file:

```bash
run_test "My new test" test_my_new_test && ((TESTS_PASSED++)) || ((TESTS_FAILED++))
```

### Best Practices

1. **Isolation**: Each test should be independent
2. **Cleanup**: Use `cleanup_test_env()` to remove artifacts
3. **Descriptive Names**: Test names should clearly describe what's being tested
4. **Clear Messages**: Assertion messages should explain what was expected
5. **Skip Appropriately**: Use `skip_test()` for platform-dependent or high-cost tests
6. **Mock External Deps**: Use mock functions for git, npm, APIs to avoid real calls

## Platform Considerations

### Windows

- **Requires Git Bash** or WSL to run bash scripts
- Git Bash is included with [Git for Windows](https://git-scm.com/downloads)
- Symlink tests may require admin privileges or developer mode
- Path handling uses forward slashes internally
- Some permission tests are skipped

### Linux/macOS

- All tests should run without special permissions
- Native bash environment
- Symlink tests run normally
- Permission tests are more comprehensive

## Continuous Integration

To run in CI environments:

```bash
#!/bin/bash
set -e

# Run test suite
./tests/test-runner.sh

# Check exit code
if [ $? -eq 0 ]; then
    echo "All tests passed"
    exit 0
else
    echo "Tests failed"
    exit 1
fi
```

## Troubleshooting

### Tests Fail on Fresh Clone

Ensure test scripts are executable:

```bash
chmod +x tests/*.sh
```

### Environment Not Cleaned Up

Manually clean test workspace:

```bash
rm -rf /tmp/cpe-test-workspace-*
```

### Mock Functions Not Working

Source test-helpers.sh before running tests:

```bash
source tests/test-helpers.sh
```

## Test Coverage

Current test coverage:

| Category | Tests | Coverage |
|----------|-------|----------|
| Unit Tests | 27 | Core functions |
| Integration Tests | 11 | Full workflows |
| Error Handling | 28 | Error scenarios |
| Validation | 33 | Input/output validation |
| **Total** | **99** | **Comprehensive** |

## Contributing

When adding new features to CPE:

1. Write tests first (TDD approach)
2. Add unit tests for individual functions
3. Add integration tests for complete workflows
4. Test error conditions and edge cases
5. Validate input/output formats
6. Run full suite before committing

## License

Same as CPE - part of the Platform.Bible extension development tools.
