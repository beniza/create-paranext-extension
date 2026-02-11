# Quick Start Guide - create-paranext-extension v2.1

## TL;DR

```bash
chmod +x create-paranext-extension.sh
./create-paranext-extension.sh
# Follow the prompts - it's that easy!
```

## What This Tool Does

Automates the complete setup of a Platform.Bible extension development environment:
1. ✅ Detects/installs latest stable Platform.Bible core
2. ✅ Creates extension from official template (basic or multi)
3. ✅ Sets up all dependencies
4. ✅ Configures git workflow for easy updates
5. ✅ Builds and links extension
6. ✅ Ready to code immediately!

## Quick Examples

### Beginner: Interactive Mode
```bash
./create-paranext-extension.sh
```
Answer the prompts:
- Template type? → `1` (basic) or `2` (multi)
- Latest version? → `Y` (yes) or specify version
- Extension name? → Type your name
- Author info? → Your name

### Advanced: Command Line
```bash
# Latest version, basic template
./create-paranext-extension.sh -n "My Extension" -a "Your Name"

# Specific version
./create-paranext-extension.sh -n "My Extension" -v v0.4.0

# Multi-extension repository
./create-paranext-extension.sh -n "My Tools" -t multi

# Fast setup (skip tests)
./create-paranext-extension.sh -n "Quick Test" --skip-test

# Debugging with verbose output
./create-paranext-extension.sh --verbose -n "Debug Extension"
```

**Verbose Mode:** Use `--verbose` to see detailed debug information including:
- Script version and configuration
- System dependency versions (node, npm, git)
- All git and npm commands being executed
- File operations and path resolutions
- API calls and responses

This is helpful for troubleshooting issues or understanding what the script is doing.

## Testing the Tool

The project includes a comprehensive test suite:

```bash
# Run all tests (92 tests)
./tests/test-runner.sh

# Run specific test category
./tests/test-runner.sh --suite unit           # 25 tests
./tests/test-runner.sh --suite integration   # 11 tests
./tests/test-runner.sh --suite error-handling # 25 tests
./tests/test-runner.sh --suite validation    # 31 tests
```

See [tests/README.md](../tests/README.md) for detailed test documentation.

## After Creation

```bash
cd your-extension-name
npm start              # Build, watch for changes, and launch Platform.Bible with your extension

# Or if you want to run Platform.Bible separately:
npm run watch          # Just build and watch for changes
# Then run Platform.Bible separately
```

## When to Use Which Template?

### Basic Extension (Default)
**Choose this if:**
- Building one specific feature/tool
- Want to package and distribute independently
- Simpler project structure
- **Example:** A spelling checker extension

### Multi Extension  
**Choose this if:**
- Building multiple related extensions
- Extensions share common code/resources
- Want to maintain them all together
- **Example:** A suite of Bible study tools

## Updating Your Extension from Template

The script sets up your extension so you can easily merge future improvements:

```bash
cd your-extension
git fetch template
git merge template/main --allow-unrelated-histories
# Review and resolve any conflicts
```

## Common Issues

### Running on Windows

This script requires a bash environment. On Windows, use **Git Bash** (included with Git for Windows):

1. Install [Git for Windows](https://git-scm.com/downloads) if not already installed
2. Open **Git Bash** (not PowerShell or CMD)
3. Navigate to the script directory: `cd /c/path/to/script`
4. Run the script: `./create-paranext-extension.sh`

**Note:** Git Bash provides Unix-like tools (bash, curl, etc.) and is the recommended way to run this script on Windows.

### "curl not found"
Install curl:
- **Ubuntu/Debian:** `sudo apt-get install curl`
- **macOS:** `brew install curl`
- **Windows**: Use Git Bash (curl is included)
- **Windows/WSL:** `sudo apt-get install curl`

### "Node.js version too old"
Install Node.js 18+ or use Volta:
```bash
curl https://get.volta.sh | bash
volta install node@latest
```

### "Permission denied"
Make script executable:
```bash
chmod +x create-paranext-extension.sh
```

### Extension not appearing in Platform.Bible?
Build your extension first:
```bash
cd your-extension
npm run build
```

## What Version Should I Target?

- **Latest (v0.5.0)**: Most features, recommended for new development
- **Specific older version**: Only if you need compatibility with older Platform.Bible installations

## Help & Documentation

- **Quick help:** `./create-paranext-extension.sh --help`
- **Detailed docs:** See [README.md](README.md)
- **Manual process:** See [docs/paranext-extension-creation-prompt.md](docs/paranext-extension-creation-prompt.md)
- **Changes:** See [CHANGELOG.md](CHANGELOG.md)

## Pro Tips

1. 💡 Use `npm run watch` for live reload during development
2. 💡 The template remote is your friend - merge updates regularly  
3. 💡 Target latest version unless you have a specific reason not to
4. 💡 If you update paranext-core, rebuild your extension

## Common Questions

**Q: What's the browserslist-db prompt during installation?**  
A: This updates browser compatibility data. It's optional and safe to skip. You'll see a harmless warning if you don't update. Update later with: `npx update-browserslist-db@latest`

**Q: Should I update browserslist-db?**  
A: Only if you see warnings and want to silence them. It won't affect functionality.

## Need More Help?

- Check the [FAQ in README.md](README.md#faq)
- Review [official Paranext extension docs](https://github.com/paranext/paranext-extension-template/wiki)
- See [UPDATE_SUMMARY.md](UPDATE_SUMMARY.md) for all v2.0 changes
