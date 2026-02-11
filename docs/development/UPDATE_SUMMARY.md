# Update Summary: create-paranext-extension v2.0

## Overview

Your create-paranext-extension tool has been completely overhauled to address all identified issues and implement best practices from the Paranext development team. This is a major version bump (v1.0 → v2.0) reflecting significant improvements.

## Issues Resolved

### ✅ Issue #1: Hard-coded coupling to v0.4.0

**Solution:** Dynamic version detection
- Script now automatically fetches the latest stable release from GitHub API (currently v0.5.0)
- Users can still specify a particular version via `-v` or `--version` flag
- Interactive mode asks if user wants latest or specific version

### ✅ Issue #1a: No warning before updating paranext-core when other extensions exist

**Solution:** Extension detection and warning system
- Script scans the workspace for existing extensions (directories with `manifest.json`)
- If found, warns user that updating paranext-core might break existing extensions
- Gives user choice to continue or abort and use a separate directory
- Prevents accidental breaking changes to existing work

### ✅ Issue #1b: Always clones paranext-core even if it exists

**Solution:** Smart paranext-core handling
- Checks if `paranext-core` directory already exists
- If exists: runs `git fetch --tags` and `git checkout <version>` to update it
- If doesn't exist: clones it fresh
- More efficient and respects existing setup

### ✅ Issue #2: Only supports basic extension template

**Solution:** Multi-template support
- Interactive prompt asks user to choose between:
  - **Basic** (single extension): `paranext-extension-template`
  - **Multi** (multiple extensions): `paranext-multi-extension-template`
- Can also be specified via `-t` or `--template` flag
- Documentation explains when to use each

### ✅ Issue #2a: Deletes .git directory (questioned if recommended)

**Solution:** Follow Paranext team's recommended practice
- **No longer deletes `.git` directory**
- Instead, renames `origin` remote to `template`
- Sets up placeholder for user's repository
- This matches the official Paranext documentation approach
- Users can easily merge future template updates:
  ```bash
  git fetch template
  git merge template/main --allow-unrelated-histories
  ```

### ✅ Issue #3: Review extension setup documentation

**Solution:** Implemented best practices from official repos
- Reviewed and incorporated guidance from:
  - paranext-core README
  - paranext-extension-template README and wiki
  - paranext-multi-extension-template README
- Updated all documentation to match official recommendations
- Added links to official resources

## New Features

1. **Dynamic Version Detection**
   - Automatically fetches latest stable release
   - Graceful fallback to v0.5.0 if API call fails
   - Users can override with specific version

2. **Enhanced Safety**
   - Detects existing extensions
   - Warns before potentially breaking updates
   - Validates version availability before checkout

3. **Template Choice**
   - Interactive selection between basic and multi templates
   - Command-line flag support: `--template basic|multi`
   - Clear guidance on which to choose

4. **Improved Git Workflow**
   - Keeps git history (recommended practice)
   - Sets up template remote for updates
   - User can easily merge future improvements

5. **Better Prerequisites Check**
   - Added `curl` requirement
   - More informative messages
   - Clear guidance on what's missing

## New Command-Line Options

```bash
-v, --version VERSION   # Specify Platform.Bible version (default: latest)
-t, --template TYPE     # Choose 'basic' or 'multi' (default: basic)
```

All previous options still work as before.

## Documentation Updates

### Updated Files:
1. **README.md**
   - New features section
   - Updated requirements
   - Enhanced usage examples
   - Added "What's New in v2.0" section
   - Comprehensive FAQ

2. **CHANGELOG.md** (NEW)
   - Complete version history
   - Migration guide
   - Technical details

3. **docs/paranext-extension-creation-prompt.md**
   - Added quick start notice pointing to automated script
   - Updated version recommendations
   - Changed git workflow to keep history
   - Added template choice information

## Usage Changes

### Before (v1.0):
```bash
./create-paranext-extension.sh --name "My Extension"
# Always targeted v0.4.0
# Always used basic template
# Always deleted .git
```

### After (v2.0):
```bash
./create-paranext-extension.sh --name "My Extension"
# Interactive prompts for template type and version
# OR
./create-paranext-extension.sh \
  --name "My Extension" \
  --version v0.5.0 \
  --template basic
# Keeps git history with template remote
```

## Benefits

1. **Always Up-to-Date**: Targets latest stable Platform.Bible by default
2. **Safer**: Warns before potentially breaking changes
3. **More Flexible**: Supports both extension architectures
4. **Better Maintenance**: Can merge future template updates easily
5. **Follows Best Practices**: Aligns with official Paranext recommendations

## Migration for Existing Users

If you have extensions created with v1.0, they will continue to work. To adopt the new workflow:

```bash
cd your-existing-extension
git remote add template https://github.com/paranext/paranext-extension-template.git
```

Now you can update from the template when needed:
```bash
git fetch template
git merge template/main --allow-unrelated-histories
```

## Testing Recommendations

Before deploying, test:
1. ✅ Creating a basic extension with latest version
2. ✅ Creating a basic extension with specific version (e.g., v0.4.0)
3. ✅ Creating a multi-extension with latest version
4. ✅ Running in workspace with existing paranext-core
5. ✅ Running in workspace with existing extensions
6. ✅ Command-line argument combinations
7. ✅ Interactive mode flows

## References

- [Paranext Core v0.5.0 Release](https://github.com/paranext/paranext-core/releases/tag/v0.5.0)
- [Extension Template](https://github.com/paranext/paranext-extension-template)
- [Multi-Extension Template](https://github.com/paranext/paranext-multi-extension-template)
- [Template Update Guide](https://github.com/paranext/paranext-extension-template/wiki/Merging-Template-Changes-into-Your-Extension)

## Next Steps

1. Review the updated script and documentation
2. Test the new features in a clean environment
3. Consider updating any existing documentation that references the old workflow
4. Announce the v2.0 release with the new features

---

**Questions or issues?** The script now has comprehensive `--help` output and detailed error messages to guide users through any problems.
