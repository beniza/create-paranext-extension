# Create Paranext Extension

🚀 **Automated tool for creating Platform.Bible extensions**

A comprehensive script that sets up a complete Platform.Bible extension development environment with one command.

**Version 2.0** - Now with dynamic version detection, multi-template support, and improved safety checks!

## Quick Start

```bash
# Make executable (first time only)
chmod +x create-paranext-extension.sh

# Create a new extension interactively
./create-paranext-extension.sh

# Or create with command-line arguments
./create-paranext-extension.sh --name "My Extension" --author "Your Name"
```

## Features

✨ **Complete Automation**
- Automatically detects and uses latest stable Platform.Bible release (currently v0.5.0)
- Option to target specific versions for compatibility
- Handles both basic and multi-extension templates
- Installs dependencies and builds project
- Creates welcome webview with congratulations message

🎯 **Smart Setup**
- Validates prerequisites (Node.js, Git, curl, etc.)
- **NEW:** Detects existing extensions and warns before updating paranext-core
- **NEW:** Intelligently updates existing paranext-core instead of re-cloning
- **NEW:** Supports both single and multi-extension project structures
- Handles naming conventions automatically
- Creates proper TypeScript/React structure
- Includes Tailwind CSS styling
- Follows Platform.Bible best practices

⚡ **Ready to Use**
- Extension appears in Platform.Bible immediately after building
- Welcome screen guides next steps
- Full development workflow included
- **NEW:** Sets up template remote for easy future updates (recommended by Paranext team)

🔐 **Safety First**
- Checks for existing extensions before updating paranext-core
- Warns about potential breaking changes
- Allows user to choose separate directory for new extension
- Validates version availability before checkout

## What You Get

```
your-extension/
├── src/
│   ├── main.ts                 # Extension entry point
│   ├── types/                  # TypeScript declarations
│   └── web-views/
│       └── welcome.web-view.tsx # Welcome screen
├── package.json                # Dependencies & scripts
├── manifest.json              # Extension metadata
├── tsconfig.json              # TypeScript config
├── tailwind.config.ts         # Styling config
└── .gitignore                 # Git ignore rules
```

## Documentation

- **[Extension Creation Guide](docs/paranext-extension-creation-prompt.md)** - Step-by-step manual process
- **[Script Usage Guide](docs/script-usage-guide.md)** - Detailed script documentation
- **[Workspace Setup Guide](docs/workspace-setup-guide.md)** - Platform.Bible development setup

## FAQ

### Should I delete the .git directory and start fresh?

**No!** This script follows the Paranext team's recommended practice of keeping the git history and setting up the template as a remote. This allows you to:
- Merge future template updates easily
- Keep track of your changes separately from template changes
- Avoid merge conflicts from duplicated diffs

### Which template should I choose - basic or multi?

- **Basic Extension**: Choose this if you're building a single extension that will be packaged and distributed independently.
- **Multi Extension**: Choose this if you're building multiple related extensions that should be maintained together in one repository.

### What if I have existing extensions when updating paranext-core?

The script will detect existing extensions and warn you before updating paranext-core. You have two options:
1. Continue and update (your existing extensions might break if there are API changes)
2. Create your new extension in a separate directory with the appropriate paranext-core version

### How do I switch to a different Platform.Bible version?

If you need to switch to a different Platform.Bible version later:

```bash
cd paranext-core
git fetch --tags
git checkout v0.4.0  # or any other version
npm install
npm run build
```

Then rebuild your extension to ensure compatibility.

## Documentation

- **[Extension Creation Guide](docs/paranext-extension-creation-prompt.md)** - Step-by-step manual process
- **[Script Usage Guide](docs/script-usage-guide.md)** - Detailed script documentation
- **[Workspace Setup Guide](docs/workspace-setup-guide.md)** - Platform.Bible development setup

## Requirements

- **Node.js 18+** (22.15.1+ recommended, Volta recommended for version management)
- **Git** with GitHub access
- **curl** for API calls
- **Platform.Bible** (script sets this up automatically at the version you choose)

## What's New in v2.0

🎉 **Major Improvements:**

1. **Dynamic Version Detection** - Automatically fetches and uses the latest stable Platform.Bible release
2. **Multi-Template Support** - Choose between basic (single extension) or multi (multiple extensions in one repo) templates
3. **Safety Checks** - Warns if existing extensions might be affected when updating paranext-core
4. **Smart paranext-core Handling** - Updates existing clone instead of re-cloning
5. **Template Update Support** - Sets up git remote following Paranext team's recommended practice
6. **Improved Git Workflow** - Keeps git history and sets up template remote for future updates

## How to Update Your Extension from Template (NEW!)

The script now follows Paranext team's recommended practice by setting up a template remote. To update your extension with the latest template improvements:

```bash
cd your-extension
git fetch template
git merge template/main --allow-unrelated-histories
```

**Note:** Review and resolve any merge conflicts carefully to preserve your custom code.

## Requirements

- **Node.js 22.16.0+** (Volta recommended)
- **Git** with GitHub access
- **Platform.Bible v0.4.0** (script sets this up automatically)

## Usage Examples

### Interactive Mode (Recommended for Beginners)
```bash
./create-paranext-extension.sh
# Follow the prompts to:
# - Choose extension template type (basic or multi)
# - Select Platform.Bible version (latest or specific)
# - Enter your extension details
```

### Command Line Mode (Automation Friendly)
```bash
# Create extension with latest Platform.Bible version
./create-paranext-extension.sh \
  --name "Scripture Memory Helper" \
  --author "John Doe" \
  --publisher "myOrg" \
  --description "Helps users memorize Bible verses"

# Target a specific Platform.Bible version
./create-paranext-extension.sh \
  --name "My Extension" \
  --version v0.5.0

# Create a multi-extension repository
./create-paranext-extension.sh \
  --name "My Tools" \
  --template multi
```

### Advanced Usage
```bash
# Skip optional steps for faster setup
./create-paranext-extension.sh \
  --name "Quick Test" \
  --skip-deps \
  --skip-test
```
cd ../paranext-core
npm start
```

## Extension Types Supported

- **WebView Extensions** - UI components with React
- **Service Extensions** - Background services and APIs
- **Hybrid Extensions** - Combination of UI and services
- **Data Provider Extensions** - Scripture and content providers

## Contributing

Found an issue or want to improve the script? Feel free to:
- Report bugs or request features
- Submit pull requests
- Share extension templates
- Improve documentation

## License

This tool follows the same license as Platform.Bible core.

---

**Happy extension building!** 🛠️✨
