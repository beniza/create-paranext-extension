# Create Paranext Extension (CPE) - Specification

**Version:** 2.0.0  
**Last Updated:** February 11, 2026  
**Status:** Under review  
**Purpose:** Single Source of Truth for CPE Tool  
**Disclaimer:** Created with the help of Claude Sonnet 4.5  
**Implementations:** Shell Script (primary), Python, Node.js (future)

---

## Table of Contents

1. [Overview](#overview)
2. [Design Philosophy](#design-philosophy)
3. [Prerequisites](#prerequisites)
4. [Configuration Schema](#configuration-schema)
5. [Workflow Specification](#workflow-specification)
6. [Operations Specification](#operations-specification)
7. [User Interaction Flows](#user-interaction-flows)
8. [Error Handling](#error-handling)
9. [Output Specification](#output-specification)
10. [Implementation Notes](#implementation-notes)

---

## Overview

### Purpose
Automate the complete setup of a Platform.Bible extension development environment, following official Paranext team best practices.

### Goals
- Minimize manual setup steps from ~30 to 1
- Ensure consistency across developer environments
- Follow Paranext team's recommended practices
- Support both basic and multi-extension architectures
- Enable easy template updates via git remote patterns
- Target latest stable or specific Platform.Bible versions

### Scope
- Create extension project from official templates
- Set up Platform.Bible core at specified version
- Configure development environment
- Initialize git repository with proper remotes
- Install dependencies and verify build
- Create symlinks for Platform.Bible integration

---

## Design Philosophy

### Core Principles

```yaml
principles:
  - name: Safety First
    description: Warn before potentially destructive operations
    examples:
      - Detect existing extensions before updating paranext-core
      - Confirm directory removal if exists
      - Validate version availability before checkout
  
  - name: Smart Defaults
    description: Use sensible defaults, allow overrides
    examples:
      - Latest stable version as default
      - Basic template as default
      - Current directory as workspace
  
  - name: Fail Fast
    description: Validate early, provide clear error messages
    examples:
      - Check prerequisites before starting
      - Validate inputs before proceeding
      - Provide actionable error messages
  
  - name: Idempotent Operations
    description: Running twice should be safe
    examples:
      - Update existing paranext-core instead of re-cloning
      - Check if directory exists before creating
      - Skip steps if already completed
  
  - name: Follow Official Practices
    description: Align with Paranext team recommendations
    examples:
      - Keep git history, set up template remote
      - Target specific stable versions, not main
      - Use recommended project structures
```

---

## Prerequisites

### Required Software

```yaml
prerequisites:
  required:
    - name: git
      version: any
      check_command: "git --version"
      install_url: "https://git-scm.com/downloads"
      purpose: Version control and template cloning
    
    - name: node
      version: ">=18.0.0"
      recommended: "22.15.1+"
      check_command: "node --version"
      install_url: "https://nodejs.org/ or https://volta.sh/"
      purpose: JavaScript runtime for Platform.Bible
    
    - name: npm
      version: any
      check_command: "npm --version"
      install_url: "Bundled with Node.js"
      purpose: Package management
  
  recommended:
    - name: curl
      version: any
      check_command: "curl --version"
      install_url: "https://curl.se/download.html"
      purpose: API calls for dynamic version detection (falls back to v0.5.0 if unavailable)
      note: Enables automatic detection of latest Platform.Bible release
    
    - name: volta
      purpose: Node.js version management
      install_url: "https://volta.sh/"
    
    - name: dotnet
      version: "8.0+"
      purpose: Platform.Bible core C# components
      install_url: "https://dotnet.microsoft.com/download"
```

---

## Configuration Schema

### Command-Line Arguments

**Usage Guidance:** Command-line arguments allow for automated setup and scripting. Use them when you know your requirements in advance or for CI/CD pipelines. For interactive exploration, run without arguments to be guided through each choice.

```yaml
cli_arguments:
  flags:
    - name: help
      short: -h
      long: --help
      type: boolean
      description: Show help message and exit
      default: false
      guidance: Use this to see all available options and examples before running
    
    - name: name
      short: -n
      long: --name
      type: string
      description: Extension name (human-readable)
      required: false
      prompt_if_missing: true
      example: "Scripture Reference Helper"
      guidance: |
        Choose a descriptive name that clearly indicates your extension's purpose.
        This will be converted to kebab-case for files, camelCase for code identifiers,
        and PascalCase for components. Avoid special characters other than spaces and hyphens.
    
    - name: author
      short: -a
      long: --author
      type: string
      description: Author name
      default: "Your Name"
      prompt_if_missing: false
      guidance: Your name or the primary maintainer's name. This appears in package.json and manifest.json
    
    - name: publisher
      short: -p
      long: --publisher
      type: string
      description: Publisher name
      default: "yourPublisher"
      prompt_if_missing: false
      guidance: |
        A unique identifier for your organization or personal namespace.
        Use lowercase alphanumeric characters. This helps avoid naming conflicts
        in the Platform.Bible extension ecosystem.
    
    - name: description
      short: -d
      long: --description
      type: string
      description: Extension description
      default: "A Platform.Bible extension"
      prompt_if_missing: false
      guidance: A brief summary of what your extension does. This appears in the extension marketplace and helps users understand your extension's purpose.
    
    - name: workspace
      short: -w
      long: --workspace
      type: path
      description: Workspace directory
      default: "."
      validation: must_exist_or_creatable
      guidance: |
        The directory where your extension and paranext-core will be located.
        Both the extension and paranext-core should be in the same parent directory
        for proper symlink integration. Use current directory (.) if you're already
        in your workspace, or specify an absolute/relative path.
    
    - name: version
      short: -v
      long: --version
      type: string
      description: Platform.Bible target version
      default: "latest"
      validation: must_be_valid_git_tag
      examples:
        - "latest"
        - "v0.5.0"
        - "v0.4.0"
      guidance: |
        Target a specific Platform.Bible release or use "latest" for the most recent stable version.
        Recommendation: Use "latest" unless you have a specific reason to target an older version
        (e.g., compatibility with existing extensions). Check release notes for breaking changes
        between versions at https://github.com/paranext/paranext-core/releases
    
    - name: template
      short: -t
      long: --template
      type: enum
      description: Extension template type
      options:
        - basic
        - multi
      default: basic
      prompt_if_missing: false
      guidance: |
        Choose the template that matches your project structure:
        - basic: Single extension with focused functionality (recommended for most cases)
        - multi: Multiple related extensions in one repository (for complex projects with
          shared code where extensions work together as a suite)
        
        When to use multi:
        - You're building a family of related extensions (e.g., "Bible Study Suite")
        - Extensions share significant code/resources
        - Extensions should be versioned and released together
        
        When to use basic:
        - Single-purpose extension
        - Simpler project structure
        - Independent versioning/releases
        - Learning or prototyping
    
    - name: skip-deps
      long: --skip-deps
      type: boolean
      description: Skip dependency installation
      default: false
      guidance: |
        Skip npm install for faster setup when:
        - You'll install dependencies manually later
        - Running in CI/CD with separate dependency stages
        - Iterating on CPE development/testing
        Note: You'll need to run 'npm install' manually before building
    
    - name: skip-git
      long: --skip-git
      type: boolean
      description: Skip git initialization
      default: false
      guidance: |
        Skip git setup when:
        - Extension already has git initialized
        - You'll set up version control manually
        - Testing/development scenarios
        Note: You'll miss automatic template remote setup for future updates
    
    - name: skip-test
      long: --skip-test
      type: boolean
      description: Skip build test
      default: false
      guidance: |
        Skip the build verification when:
        - You want faster setup and will test later
        - Running in environments with limited resources
        - Debugging setup issues (isolate problems)
        Note: Build may fail later if setup has issues
```

### Runtime Constants

```yaml
constants:
  # GitHub API
  github_api:
    paranext_core_releases: "https://api.github.com/repos/paranext/paranext-core/releases/latest"
    timeout_seconds: 10
  
  # Git repositories
  repositories:
    paranext_core: "https://github.com/paranext/paranext-core.git"
    basic_template: "https://github.com/paranext/paranext-extension-template.git"
    multi_template: "https://github.com/paranext/paranext-multi-extension-template.git"
  
  # File patterns
  file_patterns:
    extension_marker: "manifest.json"
    exclude_dirs:
      - "paranext-core"
      - "node_modules"
      - ".git"
  
  # Naming conventions
  naming:
    source_template_placeholder: "paranext-extension-template"
    remote_names:
      template: "template"
      user_repo: "origin"
```

---

## Workflow Specification

### Main Execution Flow

```yaml
workflow:
  name: Main Extension Creation Flow
  steps:
    - id: init
      name: Initialize
      operations:
        - display_header
        - parse_cli_arguments
        - validate_arguments
    
    - id: prerequisites
      name: Check Prerequisites
      operations:
        - check_required_software
        - check_software_versions
        - report_missing_prerequisites
      exit_on_failure: true
    
    - id: interactive_input
      name: Get User Input
      condition: name_not_provided_via_cli
      operations:
        - prompt_template_type
        - prompt_version_preference
        - prompt_extension_name
        - generate_name_variations
        - confirm_name_variations
        - prompt_author_info
        - prompt_publisher_info
        - prompt_description
        - prompt_workspace_dir
    
    - id: cli_defaults
      name: Apply CLI Defaults
      condition: name_provided_via_cli
      operations:
        - generate_name_variations
        - apply_default_values
        - resolve_version_latest
    
    - id: core_setup
      name: Setup Platform.Bible Core
      operations:
        - resolve_workspace_path
        - check_existing_extensions
        - warn_if_extensions_exist
        - setup_or_update_paranext_core
        - verify_core_version
        - install_core_dependencies
        - build_core
      error_recovery: prompt_user_on_critical_failure
    
    - id: template_setup
      name: Setup Extension Template
      operations:
        - check_directory_conflict
        - clone_template
        - setup_git_remotes
        - rename_template_files
        - update_file_contents
    
    - id: extension_config
      name: Configure Extension
      operations:
        - create_welcome_webview
        - update_package_json
        - update_manifest_json
        - update_types_file
        - update_readme
        - update_display_data
    
    - id: integration
      name: Integrate with Platform.Bible
      operations:
        - create_extension_symlink
      error_recovery: warn_but_continue
    
    - id: dependencies
      name: Install Dependencies
      condition: not_skip_deps
      operations:
        - install_npm_packages
      error_recovery: warn_but_continue
    
    - id: git_commit
      name: Git Initialization
      condition: not_skip_git
      operations:
        - stage_all_files
        - create_initial_commit
        - display_git_instructions
    
    - id: verification
      name: Verify Build
      condition: not_skip_test
      operations:
        - run_build_command
        - verify_dist_created
      error_recovery: warn_but_continue
    
    - id: completion
      name: Show Completion
      operations:
        - display_summary
        - display_next_steps
        - display_update_instructions
```

---

## Operations Specification

### Core Operations

Each operation defined with inputs, outputs, and behavior:

```yaml
operations:
  
  # Version Detection
  - id: get_latest_paranext_version
    name: Get Latest Paranext Version
    description: Fetch latest stable release from GitHub API
    inputs: []
    outputs:
      - name: version_tag
        type: string
        format: "v0.0.0"
    behavior:
      - curl GitHub API endpoint
      - parse JSON response for tag_name
      - fallback to v0.5.0 if API fails
      - validate version format
    error_handling:
      - timeout: use fallback version
      - api_error: use fallback version
      - invalid_format: use fallback version
    implementation_notes:
      shell: "curl -s with grep/sed parsing"
      python: "requests library with json parsing"
      node: "axios or fetch with JSON.parse"
  
  # Extension Detection
  - id: check_existing_extensions
    name: Check for Existing Extensions
    description: Scan workspace for extension projects
    inputs:
      - name: workspace_dir
        type: path
    outputs:
      - name: extensions_found
        type: boolean
      - name: extension_list
        type: array[string]
    behavior:
      - recursively search workspace_dir (max depth 2)
      - find directories containing manifest.json
      - exclude paranext-core directory
      - return list of extension names
    error_handling:
      - permission_denied: skip directory, continue
      - path_not_found: return empty list
  
  # Paranext Core Setup
  - id: setup_or_update_paranext_core
    name: Setup or Update Paranext Core
    description: Clone or update paranext-core to target version
    inputs:
      - name: workspace_dir
        type: path
      - name: target_version
        type: string
      - name: warn_if_extensions
        type: boolean
    outputs:
      - name: core_ready
        type: boolean
      - name: core_path
        type: path
    behavior:
      - check if paranext-core directory exists
      - if exists:
          - display "updating existing core"
          - cd paranext-core
          - git fetch --tags
          - git checkout target_version
      - if not exists:
          - display "cloning core"
          - git clone paranext-core repo
          - cd paranext-core
          - git checkout target_version
      - verify checkout succeeded
    error_handling:
      - version_not_found: list available versions, exit
      - git_error: display error, exit
      - permission_denied: display error, exit
    validation:
      - target_version must exist in repo
      - directory must be writable
  
  # Name Generation
  - id: generate_name_variations
    name: Generate Name Variations
    description: Convert human name to kebab, camel, and pascal case
    inputs:
      - name: human_name
        type: string
        example: "Scripture Reference Helper"
    outputs:
      - name: kebab_case
        type: string
        example: "scripture-reference-helper"
      - name: camel_case
        type: string
        example: "scriptureReferenceHelper"
      - name: pascal_case
        type: string
        example: "ScriptureReferenceHelper"
    behavior:
      - kebab_case:
          - lowercase all characters
          - replace non-alphanumeric with hyphens
          - remove leading/trailing hyphens
          - collapse multiple hyphens
      - camel_case:
          - split kebab_case on hyphens
          - lowercase first word
          - capitalize first letter of subsequent words
          - join without separators
      - pascal_case:
          - take camel_case
          - capitalize first letter
    validation:
      - kebab_case must not be empty
      - kebab_case must be valid directory name
  
  # Template Cloning
  - id: clone_template
    name: Clone Template Repository
    description: Clone appropriate template based on type
    inputs:
      - name: template_type
        type: enum[basic, multi]
      - name: target_directory
        type: path
    outputs:
      - name: template_path
        type: path
    behavior:
      - select repository URL based on template_type
      - git clone repository to target_directory
      - verify clone succeeded
    error_handling:
      - directory_exists: prompt for removal or exit
      - git_error: display error, exit
      - network_error: display error, exit
  
  # Git Remote Setup
  - id: setup_git_remotes
    name: Setup Git Remotes
    description: Configure template remote per Paranext best practices
    inputs:
      - name: repo_path
        type: path
    outputs:
      - name: remotes_configured
        type: boolean
    behavior:
      - cd repo_path
      - git remote rename origin template
      - git remote add origin "YOUR_REPO_URL_HERE"
      - display instructions for setting user's repo URL
    error_handling:
      - remote_not_found: warn but continue
      - git_error: warn but continue
  
  # File Content Updates
  - id: update_file_contents
    name: Update File Contents
    description: Replace template placeholders with user values
    inputs:
      - name: extension_path
        type: path
      - name: replacements
        type: map[string, string]
    outputs:
      - name: files_updated
        type: integer
    behavior:
      - for each file in target_files:
          - read file content
          - for each replacement:
              - find placeholder
              - replace with value
          - write file content
      - count successful updates
    target_files:
      - package.json
      - manifest.json
      - src/types/*.d.ts
      - README.md
      - assets/displayData.json
    replacements_map:
      paranext-extension-template: "{kebab_name}"
      paranextExtensionTemplate: "{camel_name}"
      "Your Name": "{author_name}"
      yourPublisher: "{publisher_name}"
      "A Platform.Bible extension": "{description}"
    error_handling:
      - file_not_found: warn, skip file
      - permission_denied: error, exit
      - encoding_error: warn, skip file
  
  # Symlink Creation
  - id: create_extension_symlink
    name: Create Extension Symlink
    description: Link extension dist to paranext-core extensions folder
    inputs:
      - name: workspace_dir
        type: path
      - name: extension_name
        type: string
    outputs:
      - name: symlink_created
        type: boolean
    behavior:
      - source: workspace_dir/extension_name/dist
      - target: workspace_dir/paranext-core/extensions/dist/extension_name
      - verify target directory exists
      - remove existing symlink if exists
      - create symlink
    error_handling:
      - target_not_found: error, provide build instructions
      - permission_denied: error, show manual instructions
      - symlink_exists_not_link: error, prompt for removal
    notes:
      - source may not exist yet (created on build)
      - provide clear message about building extension
```

### User Interaction Patterns

```yaml
interactions:
  
  # Template Type Selection
  - id: prompt_template_type
    type: menu_choice
    message: |
      Extension Template Type:
        1. Basic Extension (single extension)
        2. Multi Extension (multiple related extensions in one repo)
    prompt: "Select template type (1 or 2, default: 1): "
    validation:
      - allowed_values: ["1", "2", ""]
      - default: "1"
    mapping:
      "1": basic
      "2": multi
      "": basic
  
  # Version Selection
  - id: prompt_version_preference
    type: yes_no
    message: "Use latest stable Platform.Bible release?"
    prompt: "(Y/n): "
    default: yes
    actions:
      yes: use_latest_version
      no: prompt_specific_version
  
  - id: prompt_specific_version
    type: text_input
    message: "Enter specific version (e.g., v0.4.0): "
    validation:
      - format: "v\\d+\\.\\d+\\.\\d+"
      - check_exists: true
  
  # Extension Name
  - id: prompt_extension_name
    type: text_input
    message: "📝 Enter your extension name (e.g., 'Scripture Reference Helper'): "
    validation:
      - not_empty: true
      - max_length: 100
    retry_on_invalid: true
    error_message: "Extension name cannot be empty!"
  
  # Name Confirmation
  - id: confirm_name_variations
    type: yes_no
    message: |
      Generated name variations:
        📁 Kebab-case (folders/files): {kebab_name}
        🐪 CamelCase (JS/TS identifiers): {camel_name}
        🅿️  PascalCase (components/classes): {pascal_name}
      
      Are these names correct?
    prompt: "(y/N): "
    default: no
    actions:
      no: restart_name_input
      yes: continue
  
  # Warning: Existing Extensions
  - id: warn_existing_extensions
    type: confirmation
    message: |
      ⚠️  WARNING: Existing extensions detected in this workspace!
      Updating paranext-core to {target_version} might break existing extensions.
      
      You have two options:
        1. Continue and update paranext-core (risk breaking existing extensions)
        2. Abort and create your new extension in a separate directory
    prompt: "Do you want to continue updating paranext-core? (y/N): "
    default: no
    actions:
      no: exit_with_message
      yes: continue_with_warning
```

---

## Error Handling

### Error Categories

```yaml
error_handling:
  
  categories:
    
    - name: Prerequisites Missing
      severity: critical
      action: exit
      examples:
        - git not installed
        - node not installed
        - npm not found
      message_template: |
        ❌ Missing dependencies: {missing_list}
        Please install missing dependencies and try again.
        See: {install_instructions_url}
    
    - name: Version Not Found
      severity: critical
      action: exit
      examples:
        - specified version doesn't exist
        - target tag not in repository
      message_template: |
        ❌ Version {version} not found in paranext-core repository.
        Available recent versions:
        {version_list}
    
    - name: Directory Conflict
      severity: high
      action: prompt
      examples:
        - extension directory already exists
        - paranext-core in unexpected state
      message_template: |
        ❌ Directory '{directory}' already exists!
        Remove existing directory and continue? (y/N):
    
    - name: Network Error
      severity: high
      action: fallback_or_exit
      examples:
        - API timeout
        - git clone failure
      message_template: |
        ⚠️  Network error: {error_details}
        {fallback_action}
    
    - name: Build Failure
      severity: medium
      action: warn
      examples:
        - npm install errors
        - build script errors
      message_template: |
        ⚠️  Build failed: {error_details}
        You may need to manually fix this later.
        See build output above for details.
    
    - name: Symlink Failure
      severity: low
      action: warn_with_manual_steps
      examples:
        - permission denied
        - target directory missing
      message_template: |
        ⚠️  Could not create symlink automatically.
        Manual steps:
        {manual_steps}
```

### Recovery Strategies

```yaml
recovery_strategies:
  
  - condition: api_timeout
    strategy: use_fallback_version
    details:
      fallback_version: v0.5.0
      message: "Using fallback version {fallback_version}"
  
  - condition: git_clone_network_error
    strategy: retry_with_delay
    details:
      max_retries: 3
      delay_seconds: 5
      message: "Retrying ({attempt}/{max_retries})..."
  
  - condition: directory_exists
    strategy: prompt_user
    details:
      options:
        - remove_and_continue
        - abort_operation
  
  - condition: symlink_permission_denied
    strategy: provide_manual_instructions
    details:
      message: |
        Run these commands manually:
        cd paranext-core/extensions/dist
        ln -s ../../../{extension_name}/dist {extension_name}
```

---

## Output Specification

### Terminal Output Format

```yaml
output_format:
  
  colors:
    info: blue
    success: green
    warning: yellow
    error: red
    header: blue_bold
  
  symbols:
    info: "ℹ️  "
    success: "✅ "
    warning: "⚠️  "
    error: "❌ "
    bullet: "  •"
  
  sections:
    
    - name: header
      format: |
        ==================================================
          🚀 Paranext Extension Creator
        ==================================================
    
    - name: progress
      format: "{symbol} {message}"
      examples:
        - "ℹ️  Checking prerequisites..."
        - "✅ All prerequisites met!"
        - "⚠️  Node.js version 16.0.0 detected. Version 18+ recommended."
    
    - name: summary
      format: |
        
        🎉 Extension creation completed successfully!
        
        Extension Details:
          📛 Name: {extension_name}
          📁 Directory: {kebab_name}
          👤 Author: {author_name}
          📄 Description: {description}
          🎯 Target Version: Platform.Bible {version}
          📦 Template Type: {template_type}
        
        Next steps:
          1. cd {kebab_name}
          2. Update the git remote 'origin' to point to your repository
          3. npm run build
          4. npm run watch
          5. cd ../paranext-core && npm start
    
    - name: update_instructions
      format: |
        💡 To update from the template later:
           git fetch template && git merge template/main --allow-unrelated-histories
```

### File System Output

```yaml
file_system_output:
  
  structure:
    workspace_dir:
      paranext-core/:
        description: Platform.Bible core (cloned/updated)
        version: as specified by user
      
      {extension-name}/:
        description: New extension project
        structure:
          src/:
            main.ts: Extension entry point
            types/{extension-name}.d.ts: Type definitions
            web-views/welcome.web-view.tsx: Welcome component
          
          assets/:
            displayData.json: Extension display metadata
          
          contributions/:
            description: Settings, menus, etc. contributions
          
          public/:
            description: Static assets
          
          .git/:
            description: Git repository with template remote
          
          package.json: Updated with extension details
          manifest.json: Updated with extension details
          README.md: Updated with extension name
          tsconfig.json: TypeScript configuration
          tailwind.config.ts: Tailwind CSS configuration
          webpack.config.ts: Webpack configuration
  
  symlinks:
    - source: workspace_dir/{extension-name}/dist
      target: workspace_dir/paranext-core/extensions/dist/{extension-name}
      type: symbolic_link
      note: Created after first build
```

---

## Implementation Notes

### Multi-Language Implementation Guide

```yaml
implementation_guide:
  
  language_specific:
    
    shell:
      file: create-paranext-extension.sh
      notes:
        - use bash for better array/string handling
        - set -e for fail-fast behavior
        - use realpath for absolute paths
        - sed/grep for string manipulation
        - curl for API calls
      dependencies:
        system: [bash, git, curl, sed, grep]
      
    python:
      file: create_paranext_extension.py
      notes:
        - use argparse for CLI arguments
        - use requests for API calls
        - use pathlib for path operations
        - use jinja2 for template rendering
        - use rich or colorama for colored output
      dependencies:
        packages: [requests, gitpython, jinja2, rich]
      
    nodejs:
      file: create-paranext-extension.js
      notes:
        - use commander for CLI arguments
        - use axios for API calls
        - use fs/promises for file operations
        - use simple-git for git operations
        - use chalk for colored output
      dependencies:
        packages: [commander, axios, simple-git, chalk, prompts]
  
  shared_logic:
    - version detection algorithm
    - name case conversion logic
    - placeholder replacement patterns
    - validation rules
    - error messages
  
  testing:
    unit_tests:
      - name case conversion
      - version validation
      - placeholder replacement
    
    integration_tests:
      - full workflow on clean workspace
      - full workflow with existing paranext-core
      - full workflow with existing extensions
      - error recovery scenarios
    
    e2e_tests:
      - create basic extension, build, run
      - create multi extension, build, run
      - update from template after creation
```

### Version Mapping

```yaml
version_compatibility:
  cpe_version: 2.0.0
  paranext_versions:
    minimum: v0.3.0
    recommended: v0.5.0
    latest_tested: v0.5.0
  
  breaking_changes:
    - from_version: v0.3.0
      to_version: v0.4.0
      changes:
        - project settings structure changed
        - menu contribution format updated
    
    - from_version: v0.4.0
      to_version: v0.5.0
      changes:
        - new theming system
        - webview communication updates
```

---

## Validation Rules

### Input Validation

```yaml
validation_rules:
  
  extension_name:
    - not_empty: true
    - min_length: 3
    - max_length: 100
    - allowed_chars: alphanumeric, spaces, hyphens
    - generates_valid_kebab: true
  
  version:
    - format: "^v\\d+\\.\\d+\\.\\d+(-[\\w.]+)?$"
    - resolves_latest: true
    - exists_in_repo: true
  
  workspace_dir:
    - exists_or_creatable: true
    - is_writable: true
    - not_inside_paranext_core: true
  
  template_type:
    - one_of: [basic, multi]
  
  author_name:
    - max_length: 100
    - no_validation_required: true
  
  publisher_name:
    - max_length: 100
    - no_special_chars: recommended
```

---

## Extension Points

### Customization Options

```yaml
extension_points:
  
  - name: custom_templates
    description: Support for organization-specific templates
    config:
      custom_templates:
        - name: myorg-basic
          url: https://github.com/myorg/extension-template.git
          description: MyOrg basic extension template
  
  - name: post_creation_hooks
    description: Run custom scripts after creation
    config:
      hooks:
        post_clone: path/to/script.sh
        post_build: path/to/script.sh
  
  - name: config_file
    description: Load defaults from config file
    location: ~/.cpe-config.yaml
    schema:
      default_author: string
      default_publisher: string
      default_workspace: path
      default_version: string
      custom_templates: array
```

---

## Change Log

### Specification Version History

```yaml
specification_versions:
  
  - version: 2.0.0
    date: 2026-02-11
    changes:
      - Added dynamic version detection
      - Added multi-template support
      - Added existing extension detection
      - Added template remote setup
      - Changed from deleting .git to keeping history
    
  - version: 1.0.0
    date: 2024-01-01
    changes:
      - Initial specification
      - Hard-coded to v0.4.0
      - Basic template only
      - Deleted .git and reinitialized
```

---

## References

### External Documentation

```yaml
references:
  
  paranext:
    - name: Platform.Bible Core
      url: https://github.com/paranext/paranext-core
      documentation: https://github.com/paranext/paranext-core/wiki
    
    - name: Extension Template
      url: https://github.com/paranext/paranext-extension-template
      documentation: https://github.com/paranext/paranext-extension-template/wiki
    
    - name: Multi-Extension Template
      url: https://github.com/paranext/paranext-multi-extension-template
    
    - name: Template Update Guide
      url: https://github.com/paranext/paranext-extension-template/wiki/Merging-Template-Changes-into-Your-Extension
  
  standards:
    - name: Semantic Versioning
      url: https://semver.org/
    
    - name: Conventional Commits
      url: https://www.conventionalcommits.org/
```

---

## Appendix

### Example Configurations

#### Example 1: Interactive Mode
```yaml
execution:
  mode: interactive
  inputs:
    cli_args: []
  user_responses:
    template_type: 1  # basic
    use_latest: y
    extension_name: "Scripture Memory Helper"
    author: "John Doe"
    publisher: "BibleTools"
    description: "Helps users memorize Bible verses"
  expected_output:
    extension_created: true
    directory: scripture-memory-helper
    paranext_version: v0.5.0
```

#### Example 2: Automated CLI
```yaml
execution:
  mode: automated
  inputs:
    cli_args:
      - --name "Quick Test Extension"
      - --author "Test User"
      - --version v0.4.0
      - --template basic
      - --skip-test
  expected_output:
    extension_created: true
    directory: quick-test-extension
    paranext_version: v0.4.0
    build_tested: false
```

### Glossary

```yaml
glossary:
  paranext: Platform.Bible's previous name
  platform_bible: Extensible Bible translation software
  extension: Plugin that adds functionality to Platform.Bible
  papi: Platform API - extension interface
  pdp: Project Data Provider
  webview: UI component in extension
  manifest: Extension metadata file
  kebab_case: lowercase-with-hyphens
  camelCase: firstWordLowercaseOthersCapitalized
  PascalCase: AllWordsCapitalized
```

---

**End of Specification**

*This specification is the authoritative source for all CPE implementations.*
*When implementations diverge from this spec, the spec should be updated or the implementation corrected.*
