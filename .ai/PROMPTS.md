# LLM Prompt Templates

This document contains reusable prompt templates for working with the Ubuntu Vintage Optimizer project using Large Language Models.

## Table of Contents
- [General Project Prompts](#general-project-prompts)
- [Code Development Prompts](#code-development-prompts)
- [Bug Fix Prompts](#bug-fix-prompts)
- [Feature Addition Prompts](#feature-addition-prompts)
- [Code Review Prompts](#code-review-prompts)
- [Documentation Prompts](#documentation-prompts)
- [Testing Prompts](#testing-prompts)

## General Project Prompts

### Project Introduction Prompt
```
I'm working on the Ubuntu Vintage Optimizer project - a collection of safe, interactive Bash scripts that optimize older Ubuntu systems and laptops (2015-2018 era) for better performance.

Key project principles:
- Safety first: All changes must be reversible with comprehensive backups
- User-centric: Interactive prompts with clear explanations
- Hardware focus: Dell Latitude, Lenovo ThinkPad, Intel 6th gen+ CPUs
- Ubuntu/Debian compatibility with systemd and apt

The project includes:
- optimize_laptop.sh: Main optimization script
- revert_optimizations.sh: Safe rollback functionality  
- performance_benchmark.sh: Before/after performance measurement

Please review the .ai/CONTEXT.md file for detailed technical context before proceeding.

[Your specific request here]
```

### Quick Context Prompt
```
Context: Ubuntu Vintage Optimizer - system optimization scripts for older Ubuntu laptops
Target: Dell Latitude/ThinkPad series, Intel 6th gen+, 16GB+ RAM
Safety: All changes reversible, user confirmations, comprehensive backups
Code: Bash scripts with extensive error handling and validation

[Your specific request here]
```

## Code Development Prompts

### New Script Development
```
I need to create a new script for the Ubuntu Vintage Optimizer project.

Requirements:
- Function: [Describe the functionality needed]
- Target: [Hardware/software component]
- Safety: Must include backup mechanisms and user confirmations
- Style: Follow existing code patterns in scripts/ directory
- Error handling: Comprehensive with meaningful user feedback
- Documentation: Include function headers and usage examples

Please create the script following these patterns:
1. Set -e for error handling
2. Color-coded output (GREEN=success, RED=error, YELLOW=warning)
3. User confirmation function: confirm "message"
4. Backup function: backup_file /path/to/file
5. Progress indicators: ✓ ⚠ ✗

Code should be production-ready with thorough validation.
```

### Function Enhancement
```
I need to enhance an existing function in the Ubuntu Vintage Optimizer.

Current function:
[Paste existing code]

Enhancement needed:
[Describe what needs to be added/changed]

Requirements:
- Maintain all existing safety mechanisms
- Follow project code patterns and style
- Add appropriate error handling for new functionality
- Update user feedback messages
- Preserve backwards compatibility
- Include validation for new operations

Please provide the enhanced function with explanations for changes.
```

## Bug Fix Prompts

### General Bug Fix
```
Ubuntu Vintage Optimizer Bug Report

System Information:
- Hardware: [e.g., Dell Latitude E7450]
- CPU: [e.g., Intel i5-6300U]
- RAM: [e.g., 32GB]
- OS: [e.g., Ubuntu 22.04, kernel 6.2.0-39]
- Script: [which script has the issue]

Issue Description:
[Detailed description of the problem]

Error Output:
```
[Paste error messages here]
```

Expected Behavior:
[What should happen]

Requirements for fix:
- Maintain all safety mechanisms (backups, confirmations, error handling)
- Follow existing code patterns and style
- Include comprehensive testing approach
- Update documentation if behavior changes
- Ensure fix doesn't break other functionality

Please provide a complete fix with explanation of root cause and testing recommendations.
```

### Performance Issue
```
Performance optimization needed for Ubuntu Vintage Optimizer script.

Issue:
- Script: [script name]
- Operation: [specific operation that's slow]
- Current performance: [timing/behavior]
- Expected performance: [desired improvement]

Constraints:
- Must maintain all safety checks and validations
- Cannot compromise error handling
- User experience should remain the same or improve
- Backwards compatibility required

System context:
- Target hardware: [Dell Latitude/ThinkPad series]
- Typical specs: Intel 6th gen, 16-32GB RAM, SSD
- Ubuntu 20.04+ with systemd

Please analyze the performance bottleneck and provide an optimized solution.
```

## Feature Addition Prompts

### Hardware Support Extension
```
I want to add support for [new hardware type] to Ubuntu Vintage Optimizer.

New hardware details:
- Manufacturer: [e.g., HP, ASUS]
- Series: [e.g., EliteBook, ZenBook]
- CPU: [e.g., Intel 8th gen, AMD Ryzen]
- Special considerations: [unique hardware features]

Integration requirements:
- Add hardware detection logic
- Modify existing optimizations for compatibility
- Add new hardware-specific optimizations if beneficial
- Update documentation and hardware support matrix
- Maintain backwards compatibility with existing hardware

Safety requirements:
- All new optimizations must be reversible
- Include hardware validation before applying changes
- Add appropriate user warnings for untested configurations
- Provide fallback mechanisms for unsupported features

Please provide implementation plan and code changes needed.
```

### New Optimization Feature
```
I want to add a new optimization feature to Ubuntu Vintage Optimizer.

Feature: [detailed description]
Target component: [CPU/GPU/memory/storage/network/etc.]
Expected benefit: [performance improvement expected]
Target audience: [which users would benefit]

Technical requirements:
- Must be completely reversible
- Require user confirmation before applying
- Include comprehensive error handling
- Validate system compatibility before proceeding
- Provide clear progress feedback

Safety considerations:
- What could go wrong with this optimization?
- How do we detect if the system doesn't support it?
- What's the rollback procedure if it causes issues?
- Are there any dependencies on other system components?

Please provide:
1. Implementation approach
2. Safety analysis
3. Testing methodology
4. Documentation updates needed
```

## Code Review Prompts

### Comprehensive Code Review
```
Please review this Ubuntu Vintage Optimizer code for production readiness.

Code to review:
```
[Paste code here]
```

Review criteria:
1. Safety mechanisms (backups, error handling, validation)
2. User experience (prompts, feedback, clarity)
3. Code quality (bash best practices, error checking)
4. Hardware compatibility and detection
5. Documentation and comments
6. Security considerations
7. Performance implications

Project context:
- Target: Older Ubuntu systems, Dell/Lenovo laptops
- Safety first: All changes must be reversible
- User-friendly: Clear prompts and progress indicators
- Production use: Code will be run by non-technical users

Please provide:
- Critical issues that must be fixed
- Suggestions for improvement
- Security/safety concerns
- Code quality recommendations
- Documentation needs
```

### Security Review
```
Security review needed for Ubuntu Vintage Optimizer script modification.

Code section:
```
[Paste code that modifies system files]
```

Security concerns to evaluate:
- Does this create any security vulnerabilities?
- Are file permissions handled correctly?
- Is input validation sufficient?
- Could this be exploited by malicious actors?
- Are temporary files created securely?
- Is sudo usage appropriate and minimal?

Context:
- Script runs with user privileges plus sudo for system changes
- Modifies system configuration files
- Creates backup files in user home directory
- Used by non-technical users who trust the script

Please provide security analysis and recommendations for improvement.
```

## Documentation Prompts

### README Update
```
I need to update the Ubuntu Vintage Optimizer README.md for [new feature/change].

Change made:
[Describe what was added/modified in the code]

Current README sections that may need updates:
- Features list
- Quick Start guide
- What Gets Optimized
- Supported Hardware
- Usage Examples
- Troubleshooting

Requirements:
- Maintain friendly, accessible tone
- Include practical examples
- Update any command-line examples
- Add troubleshooting entries if needed
- Keep technical accuracy
- Maintain existing structure and style

Please provide specific sections that need updates with the new content.
```

### Troubleshooting Guide
```
I need to add a troubleshooting entry for a new issue in Ubuntu Vintage Optimizer.

Issue:
[Describe the problem users are experiencing]

Symptoms:
[What users see/experience]

Cause:
[Technical reason for the issue]

Resolution:
[How to fix it]

Prevention:
[How to avoid it in the future]

Please format this as an entry for docs/TROUBLESHOOTING.md following the existing style and structure. Include:
- Clear problem description
- Step-by-step resolution
- Command examples where applicable
- Prevention tips
- Related issues if any
```

## Testing Prompts

### Test Plan Creation
```
I need a comprehensive test plan for Ubuntu Vintage Optimizer [feature/script].

Component to test:
[Script name or feature]

Test requirements:
- Functional testing: Does it work as intended?
- Safety testing: Are backups created and restorable?
- Error handling: Does it fail gracefully?
- Hardware compatibility: Works on target systems?
- User experience: Clear prompts and feedback?

Test environment:
- Dell Latitude E7450 (Intel i5-6300U, 32GB RAM, SSD)
- Ubuntu 22.04 with kernel 6.x
- Clean system vs. previously optimized system

Please provide:
1. Pre-test setup requirements
2. Detailed test cases with expected results
3. Edge cases and error conditions to test
4. Validation criteria for each test
5. Rollback testing procedures
6. Performance impact assessment

Format as a checklist that can be followed step-by-step.
```

### Bug Reproduction
```
Help me create a bug reproduction case for Ubuntu Vintage Optimizer.

Bug report:
[Paste user bug report]

System information available:
[Any system details from user]

Need to create:
1. Minimal reproduction steps
2. Expected vs actual behavior
3. System requirements for reproduction
4. Data to collect for diagnosis
5. Workaround if available

Please provide a structured reproduction guide that can be followed to recreate the issue and gather debugging information.
```

## Usage Guidelines

### Customizing Prompts
1. Replace bracketed placeholders with specific information
2. Add relevant system details and context
3. Include error messages or code snippets as needed
4. Adjust safety requirements based on the specific change

### Best Practices
1. Always include safety and reversibility requirements
2. Reference existing code patterns and styles
3. Specify target hardware and OS versions
4. Include testing and validation expectations
5. Request documentation updates when applicable

### Prompt Chaining
For complex tasks, use multiple prompts in sequence:
1. Context setting and requirement gathering
2. Implementation or analysis
3. Review and refinement
4. Testing and validation
5. Documentation updates

These prompts should help maintain consistency and quality when working with LLMs on the Ubuntu Vintage Optimizer project.