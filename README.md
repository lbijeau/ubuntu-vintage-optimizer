# Ubuntu Vintage Optimizer

A collection of safe, interactive scripts to optimize older Ubuntu systems and laptops for better performance.

[![shellcheck](https://github.com/yourusername/ubuntu-vintage-optimizer/workflows/shellcheck/badge.svg)](https://github.com/yourusername/ubuntu-vintage-optimizer/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

This toolkit provides four main scripts to help optimize your older Ubuntu system's performance:

- **🚀 All-in-One Optimizer** - Automated benchmark → optimize → compare workflow with MD report
- **📊 Performance Benchmark** - Capture baseline metrics before/after optimization
- **⚡ System Optimizer** - Apply safe performance optimizations with confirmations
- **🔄 Revert Optimizations** - Safely undo all changes with backup restoration

## Features

- ✅ **Safe & Reversible** - All changes are backed up and can be undone
- ✅ **Interactive** - Confirmation prompts for each optimization step
- ✅ **Comprehensive** - CPU, memory, storage, and graphics optimizations
- ✅ **Well-Tested** - Designed for older Ubuntu systems and laptops (2015-2018 era)
- ✅ **Documented** - Clear progress reporting and error handling

## Quick Start

### Option 1: All-in-One (Recommended)

1. **Clone and run the automated workflow:**
   ```bash
   git clone https://github.com/yourusername/ubuntu-vintage-optimizer.git
   cd ubuntu-vintage-optimizer
   chmod +x scripts/*.sh
   ./scripts/optimize_and_compare.sh
   ```
   This will automatically:
   - Run baseline benchmark
   - Apply optimizations (with confirmations)
   - Run post-optimization benchmark  
   - Generate detailed Markdown comparison report

### Option 2: Manual Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/ubuntu-vintage-optimizer.git
   cd ubuntu-vintage-optimizer
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x scripts/*.sh
   ```

3. **Capture baseline performance:**
   ```bash
   ./scripts/performance_benchmark.sh
   ```

4. **Run optimizations:**
   ```bash
   ./scripts/optimize_laptop.sh
   ```

5. **Benchmark again to see improvements:**
   ```bash
   ./scripts/performance_benchmark.sh
   ```

## What Gets Optimized

### System-Level Optimizations
- **SSD TRIM Service** - Enables automatic SSD maintenance
- **Memory Swappiness** - Reduces swap usage (ideal for 16GB+ RAM)
- **CPU Governor** - Sets performance mode for better responsiveness
- **Intel GPU** - Enables hardware acceleration features

### Software Optimizations
- **Intel Media Driver** - Hardware video acceleration
- **Firefox Guidance** - Manual steps for browser optimization

## Supported Hardware

**Tested On:**
- Dell Latitude series (E7450, E7470, etc.)
- Lenovo ThinkPad series (T460, T470, etc.)
- Intel 6th generation CPUs (Skylake) and newer
- 16GB+ RAM configurations
- Intel HD Graphics 520/530

**Should Work On:**
- Most laptops from 2015-2018 era
- Intel integrated graphics systems
- Ubuntu 18.04+ and derivative distributions

## Prerequisites

- Linux system (Ubuntu/Debian preferred)
- sudo access
- 100MB free disk space for backups

## Usage Examples

### All-in-One Workflow (Recommended)
```bash
# Complete optimization workflow with report
./scripts/optimize_and_compare.sh

# This will:
# 1. Run baseline benchmark
# 2. Apply optimizations (with prompts)
# 3. Run post-optimization benchmark
# 4. Generate detailed Markdown report
# 
# Reports saved to: ~/.laptop_reports/
# Raw benchmarks: ~/.laptop_benchmarks/
```

### Manual Usage
```bash
# Run all optimizations with prompts
./scripts/optimize_laptop.sh

# Revert all changes
./scripts/revert_optimizations.sh
```

### Performance Testing
```bash
# Before optimization
./scripts/performance_benchmark.sh

# Apply optimizations
./scripts/optimize_laptop.sh

# After optimization  
./scripts/performance_benchmark.sh

# Compare results in ~/.laptop_benchmarks/
```

### Selective Optimization
The optimizer will ask for confirmation at each step:
- ✅ Enable TRIM service
- ❌ Skip CPU governor changes
- ✅ Install Intel media driver
- etc.

## Safety Features

- **Automatic Backups** - All modified files are backed up with timestamps
- **Disk Space Checks** - Ensures sufficient space before operations
- **Validation** - Verifies changes were applied correctly
- **Error Handling** - Graceful failure recovery
- **Dependency Checks** - Warns about package dependencies before removal

## File Locations

- **Backups:** `~/.laptop_optimization_backups/`
- **Benchmarks:** `~/.laptop_benchmarks/`
- **Reports:** `~/.laptop_reports/` (Markdown comparison reports)
- **System Files Modified:**
  - `/etc/sysctl.conf` (swappiness)
  - `/etc/default/grub` (GPU parameters)
  - `/etc/systemd/system/cpu-performance.service` (CPU governor)

## Troubleshooting

### Common Issues

**Q: Script fails with permission denied**
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

**Q: GRUB update fails**
- Script automatically restores backup on GRUB failure
- Reboot to previous kernel if needed

**Q: Performance didn't improve**
- Check if reboot is required (GPU optimizations)
- Verify optimizations were applied with benchmark script
- See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for detailed guidance

### Getting Help

1. Check the [docs/](docs/) directory for detailed guides
2. Review benchmark output in `~/.laptop_benchmarks/`
3. Open an issue with system details and error messages

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development

```bash
# Test script syntax
bash -n scripts/*.sh

# Run shellcheck (if available)
shellcheck scripts/*.sh
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ IMPORTANT DISCLAIMER AND RISK NOTICE

**SYSTEM MODIFICATION SOFTWARE - USE AT YOUR OWN RISK**

This software modifies critical system files, kernel parameters, and system services. While designed with safety mechanisms, **ALL SYSTEM MODIFICATIONS CARRY INHERENT RISKS** including but not limited to:

- **System instability or failure to boot**
- **Hardware damage from improper configurations**  
- **Data loss or corruption**
- **Voided hardware warranties**
- **Security vulnerabilities**
- **Incompatibility with future system updates**

### MANDATORY SAFETY REQUIREMENTS

**YOU MUST** complete ALL of the following before using this software:

- [ ] **Create complete system backup** (not just files - full system image)
- [ ] **Test on non-production system** first
- [ ] **Verify hardware compatibility** with supported systems list
- [ ] **Read and understand all code** before execution
- [ ] **Have recovery media available** (Ubuntu installation USB/DVD)
- [ ] **Ensure stable power supply** during modifications
- [ ] **Close all important applications** and save work

### LEGAL DISCLAIMER

**NO WARRANTY - NO LIABILITY**

This software is provided "AS IS" without warranty of any kind. The developers, contributors, and distributors:

- **DISCLAIM ALL WARRANTIES** express or implied, including merchantability and fitness for purpose
- **ASSUME NO RESPONSIBILITY** for any damage, data loss, system failure, or consequential damages
- **SHALL NOT BE LIABLE** for any direct, indirect, incidental, special, or consequential damages
- **PROVIDE NO SUPPORT GUARANTEES** for system recovery or problem resolution

### YOUR RESPONSIBILITY

By using this software, **YOU ACKNOWLEDGE AND AGREE** that:

- You are solely responsible for any consequences of its use
- You have adequate technical knowledge to understand the risks
- You will not hold developers liable for any problems or damages
- You understand this may void hardware or software warranties
- You use this software entirely at your own risk and discretion

### RECOMMENDED ALTERNATIVES

Consider these safer alternatives:
- Professional system optimization services
- Manufacturer-provided optimization tools  
- Ubuntu's built-in performance settings
- Manual configuration changes (one at a time)

**If you do not agree to these terms or cannot accept these risks, DO NOT USE THIS SOFTWARE.**

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.

---

**Tested Environment:**
- Dell Latitude E7450 & Lenovo ThinkPad T460
- Intel i5-6300U CPU and similar
- 16-32GB RAM, 256-512GB SSD
- Ubuntu 20.04+ / Linux Kernel 5.x+
- Intel HD Graphics 520/530