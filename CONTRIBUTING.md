# Contributing to Laptop Optimizer

Thank you for your interest in contributing to the Laptop Optimizer project! This document provides guidelines for contributing.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and improve
- Test your changes thoroughly

## How to Contribute

### Reporting Bugs

Before submitting a bug report:
1. Check existing issues to avoid duplicates
2. Test on a clean system if possible
3. Gather system information

**Bug Report Template:**
```
**System Information:**
- OS: Ubuntu 22.04
- Kernel: 6.x.x
- Hardware: Dell Model XYZ
- CPU: Intel i5-xxxx
- RAM: XXG

**Expected Behavior:**
What should happen

**Actual Behavior:**  
What actually happened

**Steps to Reproduce:**
1. Run script X
2. Select option Y
3. Error occurs

**Error Output:**
Paste error messages here
```

### Suggesting Features

Feature requests should include:
- Clear use case description
- Expected behavior
- Hardware compatibility considerations
- Safety implications

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Test thoroughly:**
   ```bash
   # Syntax check
   bash -n scripts/*.sh
   
   # Test on your system
   ./scripts/performance_benchmark.sh
   # Apply your changes
   # Test reversion
   ```
5. **Commit with clear messages:**
   ```bash
   git commit -m "Add CPU temperature monitoring to benchmark
   
   - Adds lm-sensors integration for thermal data
   - Includes temperature warnings for throttling
   - Updates documentation with new requirements"
   ```
6. **Push and create Pull Request**

## Development Guidelines

### Script Standards

- **Safety First:** All changes must be reversible
- **User Confirmation:** Interactive prompts for all modifications
- **Error Handling:** Graceful failure with meaningful messages
- **Documentation:** Clear comments explaining complex operations
- **Validation:** Verify changes were applied correctly

### Code Style

```bash
# Use consistent function naming
function_name() {
    local variable="value"
    
    if condition; then
        action
    fi
}

# Error handling pattern
if ! some_command; then
    echo -e "${RED}✗ Operation failed${NC}"
    return 1
fi

# Success confirmation
echo -e "${GREEN}✓ Operation completed${NC}"
```

### Testing Requirements

- **Syntax Check:** `bash -n script.sh`
- **Manual Testing:** Test all code paths
- **Reversion Testing:** Ensure backups work correctly
- **Documentation:** Update relevant docs

### Hardware Compatibility

When adding support for new hardware:
- Test on actual hardware when possible
- Add detection logic for unsupported systems
- Update SUPPORTED_HARDWARE.md
- Consider backwards compatibility

## Pull Request Guidelines

### PR Checklist
- [ ] Code follows project style guidelines
- [ ] Scripts pass syntax validation
- [ ] Changes are tested on target hardware
- [ ] Documentation is updated
- [ ] Commit messages are clear and descriptive
- [ ] No sensitive information is included

### PR Description Template
```
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested on Dell Latitude E7450
- [ ] Tested optimization process
- [ ] Tested reversion process
- [ ] Updated documentation

## Hardware Tested
- Model: Dell XYZ
- CPU: Intel i5-xxxx
- OS: Ubuntu 22.04

## Screenshots (if applicable)
Before/after benchmark results
```

## Project Structure

```
laptop-optimizer/
├── scripts/           # Main executable scripts
├── docs/             # Detailed documentation
├── examples/         # Sample outputs and configs
└── .github/          # GitHub-specific files
```

### Adding New Scripts

1. Place in `scripts/` directory
2. Make executable: `chmod +x scripts/new_script.sh`
3. Follow naming convention: `descriptive_name.sh`
4. Add to README.md usage section
5. Create corresponding documentation

### Documentation Standards

- **README.md:** High-level overview and quick start
- **docs/:** Detailed guides and troubleshooting
- **Inline Comments:** Explain complex logic
- **Function Headers:** Document parameters and return values

## Release Process

1. Update CHANGELOG.md with new features/fixes
2. Test on multiple hardware configurations
3. Create GitHub release with:
   - Clear release notes
   - Hardware compatibility notes
   - Breaking changes (if any)

## Questions?

- Open an issue for questions
- Check existing documentation first
- Be specific about your use case

## Recognition

Contributors will be recognized in:
- CHANGELOG.md for significant contributions
- README.md for major features
- GitHub contributors list

Thank you for helping make laptop optimization safer and more accessible!