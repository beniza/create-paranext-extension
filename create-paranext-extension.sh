#!/bin/bash

# Paranext Extension Creator Script
# Automates the creation of a new Paranext extension from the template
# Author: Platform.Bible Developer Community
# Version: 2.0

set -e  # Exit on any error

# Script version
SCRIPT_VERSION="2.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default paranext-core version (can be overridden)
PARANEXT_VERSION="latest"
EXTENSION_TEMPLATE_TYPE="basic"  # basic or multi
VERBOSE=false

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" >&2
}

print_debug() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}🔍 DEBUG: $1${NC}" >&2
    fi
}

print_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}📋 $1${NC}" >&2
    fi
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" >&2
}

print_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

print_header() {
    echo -e "${BLUE}" >&2
    echo "==================================================" >&2
    echo "  🚀 Paranext Extension Creator" >&2
    echo "==================================================" >&2
    echo -e "${NC}" >&2
}

# Function to convert string to different cases
to_kebab_case() {
    local result=$(echo "$1" | sed 's/[^a-zA-Z0-9]/-/g' | sed 's/--*/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-\|-$//g')
    print_debug "to_kebab_case('$1') -> '$result'"
    echo "$result"
}

to_camel_case() {
    local kebab="$1"
    local result=$(echo "$kebab" | sed 's/-\([a-z]\)/\U\1/g')
    print_debug "to_camel_case('$kebab') -> '$result'"
    echo "$result"
}

to_pascal_case() {
    local camel="$1"
    local result="${camel^}"
    print_debug "to_pascal_case('$camel') -> '$result'"
    echo "$result"
}

# Function to get latest stable release version from GitHub
get_latest_paranext_version() {
    print_info "Fetching latest Platform.Bible release version..."
    print_debug "Calling GitHub API: https://api.github.com/repos/paranext/paranext-core/releases/latest"
    
    # Try to get the latest release version from GitHub API
    local latest_version=$(curl -s "https://api.github.com/repos/paranext/paranext-core/releases/latest" | grep '"tag_name"' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
    print_debug "API returned version: '$latest_version'"
    
    if [ -z "$latest_version" ]; then
        print_warning "Could not fetch latest version. Using v0.5.0 as fallback."
        echo "v0.5.0"
    else
        print_success "Latest stable release: $latest_version"
        echo "$latest_version"
    fi
}

# Function to check if there are existing extensions in the workspace
check_existing_extensions() {
    local workspace_dir="$1"
    local extensions=()
    
    # Look for directories with manifest.json (excluding paranext-core itself)
    while IFS= read -r -d '' manifest; do
        local dir=$(dirname "$manifest")
        local dirname=$(basename "$dir")
        # Skip paranext-core extensions folder
        if [[ "$dir" != *"paranext-core"* ]]; then
            extensions+=("$dirname")
        fi
    done < <(find "$workspace_dir" -maxdepth 2 -name "manifest.json" -print0 2>/dev/null)
    
    if [ ${#extensions[@]} -gt 0 ]; then
        return 0  # Extensions found
    else
        return 1  # No extensions found
    fi
}

# Function to validate prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    print_verbose "Checking system for required dependencies..."
    
    local missing_deps=()
    
    # Check for curl (needed for API calls)
    print_debug "Checking for curl..."
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
        print_debug "curl: NOT FOUND"
    else
        print_debug "curl: $(command -v curl)"
    fi
    
    # Check for git
    print_debug "Checking for git..."
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
        print_debug "git: NOT FOUND"
    else
        print_debug "git: $(command -v git) (version: $(git --version | cut -d' ' -f3))"
    fi
    
    # Check for npm
    print_debug "Checking for npm..."
    if ! command -v npm &> /dev/null; then
        missing_deps+=("npm")
        print_debug "npm: NOT FOUND"
    else
        print_debug "npm: $(command -v npm) (version: $(npm --version))"
    fi
    
    # Check for node
    print_debug "Checking for node..."
    if ! command -v node &> /dev/null; then
        missing_deps+=("node")
        print_debug "node: NOT FOUND"
    else
        # Check Node.js version
        local node_version=$(node --version | sed 's/v//')
        local major_version=$(echo $node_version | cut -d. -f1)
        print_success "Node version: v$node_version"
        print_debug "node: $(command -v node) (version: v$node_version)"
        if [ "$major_version" -lt 18 ]; then
            print_warning "Node.js version $node_version detected. Version 18+ recommended."
        fi
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_info "Please install missing dependencies and try again."
        exit 1
    fi
    
    print_success "All prerequisites met!"
}

# Function to setup paranext-core with correct version
setup_paranext_core() {
    local target_version="$1"
    print_info "Setting up Platform.Bible core ($target_version)..."
    print_debug "Target version: $target_version"
    
    # Convert WORKSPACE_DIR to absolute path to avoid confusion
    WORKSPACE_DIR=$(realpath "$WORKSPACE_DIR")
    print_debug "Workspace directory (absolute): $WORKSPACE_DIR"
    cd "$WORKSPACE_DIR"
    print_verbose "Changed to workspace directory: $(pwd)"
    
    # Check for existing extensions before updating paranext-core
    if [ -d "paranext-core" ]; then
        if check_existing_extensions "$WORKSPACE_DIR"; then
            print_warning "⚠️  WARNING: Existing extensions detected in this workspace!"
            print_warning "Updating paranext-core to $target_version might break existing extensions."
            echo
            print_info "You have two options:"
            echo "  1. Continue and update paranext-core (risk breaking existing extensions)"
            echo "  2. Abort and create your new extension in a separate directory"
            echo
            read -p "Do you want to continue updating paranext-core? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "Aborted. Please run this script in a different directory."
                exit 0
            fi
        fi
    fi
    
    if [ ! -d "paranext-core" ]; then
        print_info "Cloning paranext-core repository..."
        git clone https://github.com/paranext/paranext-core.git --quiet
        print_success "paranext-core cloned!"
    else
        print_info "paranext-core already exists, will update it..."
    fi
    
    cd paranext-core
    
    # Fetch latest changes
    print_info "Fetching latest changes..."
    git fetch --tags --quiet
    
    # Check current version and switch if needed
    current_tag=$(git describe --exact-match --tags 2>/dev/null || echo "")
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    
    if [ "$current_tag" != "$target_version" ] && [ "$current_branch" != "$target_version" ]; then
        print_info "Switching to $target_version..."
        
        # First check if the target version exists
        if ! git rev-parse "$target_version" >/dev/null 2>&1; then
            print_error "Version $target_version not found. Available versions:"
            git tag -l "v*" | sort -V | tail -n 10
            exit 1
        fi
        
        # Check for local changes that might prevent checkout
        if ! git diff-index --quiet HEAD -- 2>/dev/null; then
            print_warning "Local changes detected. Stashing them..."
            git stash --quiet
        fi
        
        # Try to checkout
        if ! git checkout "$target_version" --quiet 2>&1; then
            print_error "Failed to checkout $target_version. Please check git status and try again."
            exit 1
        fi
        
        print_success "Switched to $target_version!"
    else
        print_success "Already on $target_version!"
    fi
    
    # Install dependencies if node_modules doesn't exist or is outdated
    if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
        print_info "Installing paranext-core dependencies..."
        npm install --silent
        print_success "paranext-core dependencies installed!"
    else
        print_success "paranext-core dependencies up to date!"
    fi
    
    # Build if needed
    if [ ! -d "dist" ] || [ "src" -nt "dist" ]; then
        print_info "Building paranext-core..."
        npm run build --silent
        print_success "paranext-core built!"
    else
        print_success "paranext-core already built!"
    fi
    
    cd "$WORKSPACE_DIR"
    print_success "Platform.Bible core ($target_version) ready!"
}

# Function to prompt for user input
get_user_input() {
    print_info "Please provide the following information:"
    echo
    
    # Ask about extension template type
    if [ -z "$EXTENSION_TEMPLATE_TYPE" ] || [ "$EXTENSION_TEMPLATE_TYPE" = "basic" ]; then
        echo "Extension Template Type:"
        echo "  1. Basic Extension (single extension)"
        echo "  2. Multi Extension (multiple related extensions in one repo)"
        echo
        read -p "Select template type (1 or 2, default: 1): " template_choice
        echo
        
        case $template_choice in
            2)
                EXTENSION_TEMPLATE_TYPE="multi"
                print_info "Using multi-extension template"
                ;;
            *)
                EXTENSION_TEMPLATE_TYPE="basic"
                print_info "Using basic extension template"
                ;;
        esac
    fi
    
    # Get paranext-core version preference
    if [ "$PARANEXT_VERSION" = "latest" ]; then
        echo
        read -p "Use latest stable Platform.Bible release? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            read -p "Enter specific version (e.g., v0.4.0): " PARANEXT_VERSION
        else
            PARANEXT_VERSION=$(get_latest_paranext_version)
        fi
    fi
    
    print_info "Will target Platform.Bible version: $PARANEXT_VERSION"
    echo
    
    # Get extension name
    while [ -z "$EXTENSION_NAME" ]; do
        read -p "📝 Enter your extension name (e.g., 'Scripture Reference Helper'): " EXTENSION_NAME
        if [ -z "$EXTENSION_NAME" ]; then
            print_warning "Extension name cannot be empty!"
        fi
    done
    
    # Generate case variations
    KEBAB_NAME=$(to_kebab_case "$EXTENSION_NAME")
    CAMEL_NAME=$(to_camel_case "$KEBAB_NAME")
    PASCAL_NAME=$(to_pascal_case "$CAMEL_NAME")
    
    echo
    print_info "Generated name variations:"
    echo "  📁 Kebab-case (folders/files): $KEBAB_NAME"
    echo "  🐪 CamelCase (JS/TS identifiers): $CAMEL_NAME"
    echo "  🅿️  PascalCase (components/classes): $PASCAL_NAME"
    echo
    
    # Confirm names
    read -p "❓ Are these names correct? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Let's try again..."
        EXTENSION_NAME=""
        get_user_input
        return
    fi
    
    # Get author info
    read -p "👤 Enter your name (author): " AUTHOR_NAME
    [ -z "$AUTHOR_NAME" ] && AUTHOR_NAME="Your Name"
    
    read -p "🏢 Enter publisher name (optional): " PUBLISHER_NAME
    [ -z "$PUBLISHER_NAME" ] && PUBLISHER_NAME="yourPublisher"
    
    read -p "📄 Enter extension description: " DESCRIPTION
    [ -z "$DESCRIPTION" ] && DESCRIPTION="A Platform.Bible extension"
    
    # Get workspace directory
    read -p "📂 Enter workspace directory (default: current directory): " WORKSPACE_DIR
    [ -z "$WORKSPACE_DIR" ] && WORKSPACE_DIR="."
    
    echo
    print_info "Configuration complete!"
}

# Function to clone and setup the template
setup_template() {
    print_info "Setting up extension template..."
    print_verbose "Initializing template setup process..."
    
    # Ensure we're in the workspace directory, not inside paranext-core
    # Convert to absolute path to avoid any confusion
    WORKSPACE_DIR=$(realpath "$WORKSPACE_DIR")
    print_debug "Absolute workspace path: $WORKSPACE_DIR"
    cd "$WORKSPACE_DIR"
    print_debug "Current directory: $(pwd)"
    
    # Check if directory already exists
    if [ -d "$KEBAB_NAME" ]; then
        print_error "Directory '$KEBAB_NAME' already exists!"
        read -p "❓ Remove existing directory and continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$KEBAB_NAME"
            print_success "Removed existing directory"
        else
            print_error "Aborted. Please choose a different name or remove the existing directory."
            exit 1
        fi
    fi
    
    # Determine template repository based on type
    local template_repo
    if [ "$EXTENSION_TEMPLATE_TYPE" = "multi" ]; then
        template_repo="https://github.com/paranext/paranext-multi-extension-template.git"
        print_info "Cloning multi-extension template..."
        print_debug "Using multi-extension template repository"
    else
        template_repo="https://github.com/paranext/paranext-extension-template.git"
        print_info "Cloning basic extension template..."
        print_debug "Using basic extension template repository"
    fi
    
    # Clone the template
    print_debug "Executing: git clone $template_repo $KEBAB_NAME"
    git clone "$template_repo" "$KEBAB_NAME" --quiet
    
    cd "$KEBAB_NAME"
    print_debug "Changed to extension directory: $(pwd)"
    
    # Set up template as remote for future updates (recommended practice)
    print_info "Setting up template remote for future updates..."
    print_debug "Executing: git remote rename origin template"
    git remote rename origin template
    print_debug "Executing: git remote add origin YOUR_REPO_URL_HERE"
    git remote add origin "YOUR_REPO_URL_HERE"  # Placeholder for user's repo
    
    print_success "Template cloned successfully!"
    print_info "💡 Tip: You can update from the template in the future using:"
    print_info "   git fetch template && git merge template/main --allow-unrelated-histories"
}

# Function to rename files
rename_files() {
    print_info "Renaming template files..."
    print_verbose "Processing file renames for template customization..."
    
    # Rename the types file
    if [ -f "src/types/paranext-extension-template.d.ts" ]; then
        print_debug "Executing: mv src/types/paranext-extension-template.d.ts src/types/$KEBAB_NAME.d.ts"
        mv "src/types/paranext-extension-template.d.ts" "src/types/$KEBAB_NAME.d.ts"
        print_success "Renamed types file to $KEBAB_NAME.d.ts"
    else
        print_debug "Types file not found: src/types/paranext-extension-template.d.ts"
    fi
}

# Function to update file contents
update_files() {
    print_info "Updating file contents..."
    print_verbose "Replacing template placeholders with extension details..."
    
    # Update package.json
    if [ -f "package.json" ]; then
        print_debug "Updating package.json with extension details"
        # Use a more robust sed approach with temp file
        sed -e "s/\"name\": \"paranext-extension-template\"/\"name\": \"$KEBAB_NAME\"/" \
            -e "s/\"types\": \"src\/types\/paranext-extension-template\.d\.ts\"/\"types\": \"src\/types\/$KEBAB_NAME.d.ts\"/" \
            -e "s/\"author\": \"Paranext\"/\"author\": \"$AUTHOR_NAME\"/" \
            -e "s/\"description\": \".*\"/\"description\": \"$DESCRIPTION\"/" \
            package.json > package.json.tmp && mv package.json.tmp package.json
        print_success "Updated package.json"
    fi
    
    # Update manifest.json
    if [ -f "manifest.json" ]; then
        print_debug "Updating manifest.json with extension metadata"
        sed -e "s/\"name\": \"paranextExtensionTemplate\"/\"name\": \"$CAMEL_NAME\"/" \
            -e "s/\"publisher\": \"paranext\"/\"publisher\": \"$PUBLISHER_NAME\"/" \
            -e "s/\"author\": \"Paranext\"/\"author\": \"$AUTHOR_NAME\"/" \
            -e "s/\"types\": \"src\/types\/paranext-extension-template\.d\.ts\"/\"types\": \"src\/types\/$KEBAB_NAME.d.ts\"/" \
            manifest.json > manifest.json.tmp && mv manifest.json.tmp manifest.json
        print_success "Updated manifest.json"
    fi
    
    # Update types file
    if [ -f "src/types/$KEBAB_NAME.d.ts" ]; then
        sed "s/declare module 'paranext-extension-template'/declare module '$KEBAB_NAME'/" \
            "src/types/$KEBAB_NAME.d.ts" > "src/types/$KEBAB_NAME.d.ts.tmp" && \
            mv "src/types/$KEBAB_NAME.d.ts.tmp" "src/types/$KEBAB_NAME.d.ts"
        print_success "Updated types file"
    fi
    
    # Update main.ts if it exists
    if [ -f "src/main.ts" ]; then
        # Update any references to paranextExtensionTemplate
        sed -i.bak "s/paranextExtensionTemplate/$CAMEL_NAME/g" src/main.ts
        rm -f src/main.ts.bak
        print_success "Updated main.ts"
    fi
    
    # Update README.md
    if [ -f "README.md" ]; then
        cat > README.md << EOF
# $EXTENSION_NAME

$DESCRIPTION

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

[Installation instructions for end users]

## Development

### Prerequisites

- Node.js 18+ (preferably installed via Volta)
- Platform.Bible core development environment

### Building

\`\`\`bash
npm install
npm run build
\`\`\`

### Testing

\`\`\`bash
npm start
\`\`\`

### Development

\`\`\`bash
npm run watch  # Watch for changes
\`\`\`

## License

MIT
EOF
        print_success "Updated README.md"
    fi
    
    # Update displayData.json
    if [ -f "assets/displayData.json" ]; then
        cat > assets/displayData.json << EOF
{
  "displayName": {
    "en": "$EXTENSION_NAME"
  },
  "shortDescription": {
    "en": "$DESCRIPTION"
  }
}
EOF
        print_success "Updated displayData.json"
    fi
}

# Function to create welcome webview
create_welcome_webview() {
    print_info "Creating welcome webview..."
    print_verbose "Generating welcome webview component with Platform.Bible React components..."
    
    # Create web-views directory
    print_debug "Creating directory: src/web-views"
    mkdir -p "src/web-views"
    
    # Create welcome webview component
    cat > "src/web-views/welcome.web-view.tsx" << 'EOF'
import { Button } from "platform-bible-react";

globalThis.webViewComponent = function WelcomeWebView() {
  return (
    <div className="tw-p-8 tw-bg-gradient-to-br tw-from-blue-50 tw-to-indigo-100 tw-min-h-screen tw-flex tw-items-center tw-justify-center">
      <div className="tw-bg-white tw-rounded-lg tw-shadow-xl tw-p-8 tw-max-w-2xl tw-w-full">
        <div className="tw-text-center tw-mb-8">
          <h1 className="tw-text-4xl tw-font-bold tw-text-blue-600 tw-mb-4">
            🎉 Welcome to Your Extension!
          </h1>
          <p className="tw-text-xl tw-text-gray-600 tw-mb-2">
            Congratulations! Your Platform.Bible extension is working perfectly.
          </p>
          <p className="tw-text-lg tw-text-gray-500">
            You're now ready to start building amazing features for Platform.Bible.
          </p>
        </div>
        
        <div className="tw-bg-gray-50 tw-rounded-lg tw-p-6 tw-mb-6">
          <h2 className="tw-text-2xl tw-font-semibold tw-text-gray-800 tw-mb-4">
            🚀 Next Steps:
          </h2>
          <ol className="tw-list-decimal tw-list-inside tw-space-y-3 tw-text-gray-700">
            <li className="tw-text-base">
              <strong>Edit this webview:</strong> Modify <code className="tw-bg-white tw-px-2 tw-py-1 tw-rounded tw-text-sm">src/web-views/welcome.web-view.tsx</code> to create your own UI
            </li>
            <li className="tw-text-base">
              <strong>Add extension logic:</strong> Update <code className="tw-bg-white tw-px-2 tw-py-1 tw-rounded tw-text-sm">src/main.ts</code> to add functionality
            </li>
            <li className="tw-text-base">
              <strong>Watch for changes:</strong> Run <code className="tw-bg-white tw-px-2 tw-py-1 tw-rounded tw-text-sm">npm run watch</code> for live development
            </li>
            <li className="tw-text-base">
              <strong>Test your extension:</strong> Use <code className="tw-bg-white tw-px-2 tw-py-1 tw-rounded tw-text-sm">npm start</code> to build and launch Platform.Bible
            </li>
          </ol>
        </div>
        
        <div className="tw-bg-blue-50 tw-rounded-lg tw-p-6 tw-mb-6">
          <h3 className="tw-text-lg tw-font-semibold tw-text-blue-800 tw-mb-3">
            📚 Development Resources:
          </h3>
          <ul className="tw-list-disc tw-list-inside tw-space-y-2 tw-text-blue-700">
            <li>Platform.Bible Documentation: <a href="#" className="tw-underline">docs.platform.bible</a></li>
            <li>Extension API Reference: Check the types in your <code>src/types/</code> directory</li>
            <li>React Components: Use components from <code>platform-bible-react</code></li>
            <li>Styling: Utility-first CSS with Tailwind (prefix classes with <code>tw-</code>)</li>
          </ul>
        </div>
        
        <div className="tw-text-center">
          <Button className="tw-bg-blue-600 tw-text-white tw-px-6 tw-py-3 tw-rounded-lg tw-font-semibold hover:tw-bg-blue-700 tw-transition-colors">
            Start Building! 🛠️
          </Button>
        </div>
      </div>
    </div>
  );
};
EOF
    
    print_success "Created welcome webview component"
    
    # Update main.ts to include the welcome webview
    cat > "src/main.ts" << EOF
import papi, { logger } from "@papi/backend";
import type {
  ExecutionActivationContext,
  IWebViewProvider,
  SavedWebViewDefinition,
  WebViewDefinition,
} from '@papi/core';

// Import our WebView file as a string (will be bundled)
import welcomeWebView from "./web-views/welcome.web-view?inline";

const welcomeWebViewType = "${KEBAB_NAME}.welcome";

/**
 * WebView provider that provides the welcome WebView when requested
 */
const welcomeWebViewProvider: IWebViewProvider = {
  async getWebView(
    savedWebView: SavedWebViewDefinition
  ): Promise<WebViewDefinition | undefined> {
    if (savedWebView.webViewType !== welcomeWebViewType)
      throw new Error(
        \`\${welcomeWebViewType} provider received request to provide a \${savedWebView.webViewType} WebView\`
      );
    return {
      ...savedWebView,
      title: "${EXTENSION_NAME} - Welcome",
      content: welcomeWebView,
    };
  },
};

export async function activate(context: ExecutionActivationContext) {
  logger.info("${EXTENSION_NAME} extension is activating!");

  // Register the welcome webview provider
  const welcomeWebViewProviderPromise = papi.webViewProviders.registerWebViewProvider(
    welcomeWebViewType,
    welcomeWebViewProvider
  );

  // Open the welcome webview automatically
  papi.webViews.openWebView(welcomeWebViewType, undefined, { existingId: "?" });

  context.registrations.add(await welcomeWebViewProviderPromise);

  logger.info("${EXTENSION_NAME} extension finished activating!");
}

export async function deactivate() {
  logger.info("${EXTENSION_NAME} extension is deactivating!");
  return true;
}
EOF
    
    print_success "Updated main.ts with welcome webview"
}

# Function to install dependencies
install_dependencies() {
    print_info "Installing dependencies..."
    print_verbose "Running npm install to fetch project dependencies..."
    
    # Remove package-lock.json to regenerate with new name
    if [ -f "package-lock.json" ]; then
        print_debug "Removing old package-lock.json"
        rm package-lock.json
    fi
    
    # Install dependencies
    print_debug "Executing: npm install"
    npm install --silent
    
    print_success "Dependencies installed successfully!"
    
    # Check if browserslist-db update is needed (only in interactive mode)
    if [ "$INTERACTIVE_MODE" = true ]; then
        echo
        print_info "📋 Optional: Update browserslist database"
        print_info "This updates browser compatibility data used by build tools."
        print_info "Safe to skip - you may see a harmless warning if you don't update."
        echo
        read -p "Would you like to update browserslist-db now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Updating browserslist database..."
            npx update-browserslist-db@latest 2>/dev/null || print_warning "Update skipped or failed (not critical)"
            print_success "Browserslist database updated!"
        else
            print_info "Skipped. You can update later with: npx update-browserslist-db@latest"
        fi
    fi
}

# Function to create initial git commit
create_git_commit() {
    print_info "Creating initial git commit..."
    print_verbose "Staging all files and creating commit with extension metadata..."
    
    print_debug "Executing: git add ."
    git add .
    print_debug "Creating commit with extension details"
    git commit -m "Initial commit: Created $EXTENSION_NAME extension from template

Target Platform.Bible version: $PARANEXT_VERSION
Extension Template: $EXTENSION_TEMPLATE_TYPE
Created: $(date)
Kebab case: $KEBAB_NAME
Camel case: $CAMEL_NAME
Pascal case: $PASCAL_NAME

Template remote configured for future updates.
To update from template: git fetch template && git merge template/main" --quiet
    
    print_success "Initial commit created with version info!"
    print_info "💡 Remember to set your repository URL:"
    print_info "   git remote set-url origin YOUR_REPO_URL"
}

# Function to test the build
test_build() {
    print_info "Testing extension build..."
    print_verbose "Running build test to verify extension structure..."
    
    print_debug "Executing: npm run build"
    if npm run build --silent; then
        print_success "Extension builds successfully!"
        print_debug "Build completed without errors"
    else
        print_error "Build failed! Please check the output above."
        print_debug "Build command returned non-zero exit code"
        return 1
    fi
}

# Function to show completion summary
show_completion() {
    echo
    print_success "🎉 Extension creation completed successfully!"
    echo
    echo -e "${GREEN}Extension Details:${NC}"
    echo "  📛 Name: $EXTENSION_NAME"
    echo "  📁 Directory: $KEBAB_NAME"
    echo "  👤 Author: $AUTHOR_NAME"
    echo "  📄 Description: $DESCRIPTION"
    echo "  🎯 Target Version: Platform.Bible $PARANEXT_VERSION"
    echo "  📦 Template Type: $EXTENSION_TEMPLATE_TYPE"
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. cd $KEBAB_NAME"
    echo "  2. Update the git remote 'origin' to point to your repository"
    echo "  3. npm run build             # Build the extension (creates dist directory)"
    echo "  4. npm run watch             # Start development mode"
    echo "  5. npm start  # Build and launch Platform.Bible with your extension"
    echo
    echo -e "${BLUE}Development commands:${NC}"
    echo "  📦 npm run build          # Build for development"
    echo "  🔄 npm run watch          # Watch and rebuild on changes"
    echo "  🚀 npm start  # Build and launch Platform.Bible with your extension"
    echo "  🧹 npm run lint           # Check code quality"
    echo "  ✨ npm run format         # Format code"
    echo "  📋 npm run package        # Create distributable package"
    echo
    if [ "$EXTENSION_TEMPLATE_TYPE" = "multi" ]; then
        echo -e "${YELLOW}Note: This is a multi-extension repository.${NC}"
        echo -e "${YELLOW}To create additional extensions, see the multi-extension template docs.${NC}"
        echo
    fi
    echo
    echo -e "${YELLOW}💡 To update from the template later:${NC}"
    echo -e "${YELLOW}   git fetch template && git merge template/main --allow-unrelated-histories${NC}"
    echo
    print_info "Happy coding! 🚀"
}

# Function to show help
show_help() {
    echo "Paranext Extension Creator Script v2.0"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -n, --name NAME         Extension name (interactive if not provided)"
    echo "  -a, --author AUTHOR     Author name"
    echo "  -p, --publisher PUB     Publisher name"
    echo "  -d, --description DESC  Extension description"
    echo "  -w, --workspace DIR     Workspace directory (default: current)"
    echo "  -v, --version VERSION   Platform.Bible version (default: latest stable)"
    echo "  -t, --template TYPE     Template type: 'basic' or 'multi' (default: basic)"
    echo "  --skip-deps             Skip dependency installation"
    echo "  --skip-git              Skip git initialization"
    echo "  --skip-test             Skip build test"
    echo "  --verbose               Enable verbose/debug output"
    echo
    echo "Examples:"
    echo "  $0                                          # Interactive mode"
    echo "  $0 -n \"My Extension\" -a \"John Doe\"        # Semi-automated"
    echo "  $0 --name \"Bible Helper\" --version v0.5.0  # Specific version"
    echo "  $0 -n \"Tools\" -t multi                     # Multi-extension template"
    echo "  $0 --verbose -n \"Debug Extension\"          # With verbose output"
    echo
    echo "Features:"
    echo "  • Automatically detects and uses latest stable Platform.Bible release"
    echo "  • Warns if existing extensions will be affected by paranext-core update"
    echo "  • Handles existing paranext-core (update vs fresh clone)"
    echo "  • Supports both basic and multi-extension templates"
    echo "  • Sets up template remote for future updates (recommended practice)"
}

# Parse command line arguments
SKIP_DEPS=false
SKIP_GIT=false
SKIP_TEST=false
WORKSPACE_DIR="."  # Default to current directory

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -n|--name)
            EXTENSION_NAME="$2"
            shift 2
            ;;
        -a|--author)
            AUTHOR_NAME="$2"
            shift 2
            ;;
        -p|--publisher)
            PUBLISHER_NAME="$2"
            shift 2
            ;;
        -d|--description)
            DESCRIPTION="$2"
            shift 2
            ;;
        -w|--workspace)
            WORKSPACE_DIR="$2"
            shift 2
            ;;
        -v|--version)
            PARANEXT_VERSION="$2"
            shift 2
            ;;
        -t|--template)
            EXTENSION_TEMPLATE_TYPE="$2"
            shift 2
            ;;
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --skip-git)
            SKIP_GIT=true
            shift
            ;;
        --skip-test)
            SKIP_TEST=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            print_debug "Verbose mode enabled"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_header
    
    # Show version and configuration in verbose mode
    print_verbose "Create Paranext Extension Script v$SCRIPT_VERSION"
    print_debug "Script invoked at: $(date)"
    print_debug "Working directory: $(pwd)"
    print_debug "User: $USER"
    print_debug "Shell: $SHELL"
    print_debug "Bash version: ${BASH_VERSION}"
    
    # Determine if we're in interactive mode (no extension name provided via command line)
    INTERACTIVE_MODE=false
    if [ -z "$EXTENSION_NAME" ]; then
        INTERACTIVE_MODE=true
        print_debug "Mode: Interactive"
    else
        print_debug "Mode: Command-line (non-interactive)"
        print_debug "Extension name: $EXTENSION_NAME"
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Get user input (skip if provided via command line)
    if [ "$INTERACTIVE_MODE" = true ]; then
        get_user_input
    else
        # Generate case variations from provided name
        KEBAB_NAME=$(to_kebab_case "$EXTENSION_NAME")
        CAMEL_NAME=$(to_camel_case "$KEBAB_NAME")
        PASCAL_NAME=$(to_pascal_case "$CAMEL_NAME")
        
        print_debug "Generated naming variations:"
        print_debug "  Kebab case: $KEBAB_NAME"
        print_debug "  Camel case: $CAMEL_NAME"
        print_debug "  Pascal case: $PASCAL_NAME"
        
        # Set defaults for optional parameters
        [ -z "$AUTHOR_NAME" ] && AUTHOR_NAME="Your Name"
        [ -z "$PUBLISHER_NAME" ] && PUBLISHER_NAME="yourPublisher"
        [ -z "$DESCRIPTION" ] && DESCRIPTION="A Platform.Bible extension"
        [ -z "$WORKSPACE_DIR" ] && WORKSPACE_DIR="."
        
        print_debug "Configuration:"
        print_debug "  Author: $AUTHOR_NAME"
        print_debug "  Publisher: $PUBLISHER_NAME"
        print_debug "  Description: $DESCRIPTION"
        print_debug "  Workspace: $WORKSPACE_DIR"
        print_debug "  Template type: $EXTENSION_TEMPLATE_TYPE"
        print_debug "  Skip deps: $SKIP_DEPS"
        print_debug "  Skip git: $SKIP_GIT"
        print_debug "  Skip test: $SKIP_TEST"
        
        # Get latest version if not specified
        if [ "$PARANEXT_VERSION" = "latest" ]; then
            PARANEXT_VERSION=$(get_latest_paranext_version)
        fi
    fi
    
    # Setup paranext-core with target version
    setup_paranext_core "$PARANEXT_VERSION"
    
    # Execute setup steps
    setup_template
    rename_files
    update_files
    create_welcome_webview
    
    if [ "$SKIP_DEPS" = false ]; then
        install_dependencies
    else
        print_warning "Skipping dependency installation"
    fi
    
    if [ "$SKIP_GIT" = false ]; then
        create_git_commit
    else
        print_warning "Skipping git initialization"
    fi
    
    if [ "$SKIP_TEST" = false ]; then
        test_build
    else
        print_warning "Skipping build test"
    fi
    
    show_completion
}

# Error handling
trap 'print_error "Script interrupted"; exit 1' INT TERM

# Run main function
main "$@"
