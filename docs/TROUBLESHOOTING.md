# Troubleshooting Guide

This guide covers common issues and their solutions when using the Laptop Optimizer scripts.

## Common Issues

### Script Execution Problems

#### Permission Denied
```bash
bash: ./optimize_laptop.sh: Permission denied
```
**Solution:**
```bash
chmod +x scripts/*.sh
```

#### Sudo Password Prompts
Scripts require sudo access for system modifications.
**Solution:**
- Ensure your user is in the sudo group
- Scripts will prompt for password when needed

### Optimization Issues

#### TRIM Service Won't Enable
```
Failed to enable TRIM service
```
**Possible Causes:**
- Not running on an SSD
- fstrim.timer already enabled
- systemd issues

**Solutions:**
```bash
# Check if you have an SSD
lsblk -d -o name,rota
# (0 = SSD, 1 = HDD)

# Check current TRIM status
systemctl status fstrim.timer

# Manual enable if needed
sudo systemctl enable --now fstrim.timer
```

#### CPU Governor Changes Don't Persist
**Symptoms:** CPU governor resets after reboot
**Solution:** The script creates a systemd service for persistence. Check:
```bash
systemctl status cpu-performance.service
systemctl is-enabled cpu-performance.service
```

#### GRUB Update Fails
```
Failed to update GRUB
```
**Safety:** Script automatically restores backup on GRUB failure
**Manual Recovery:**
```bash
# Restore from backup
sudo cp ~/.laptop_optimization_backups/grub_TIMESTAMP /etc/default/grub
sudo update-grub
```

### Performance Issues

#### No Noticeable Performance Improvement
**Diagnostics:**
1. Check if reboot is required (GPU optimizations need reboot)
2. Verify optimizations were applied:
   ```bash
   ./scripts/performance_benchmark.sh
   ```
3. Compare before/after benchmark results

**Common Causes:**
- Thermal throttling (laptop overheating)
- Background processes consuming resources
- Hardware limitations

#### System Feels Slower After Optimization
**Possible Causes:**
- CPU governor change causing different behavior
- Firefox optimizations need manual configuration
- Conflicting power management settings

**Solutions:**
```bash
# Revert optimizations
./scripts/revert_optimizations.sh

# Or revert specific components
systemctl disable cpu-performance.service
```

### Hardware Compatibility

#### Unsupported CPU Architecture
**Symptoms:** CPU governor files don't exist
**Check:**
```bash
ls /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```
If no files exist, your CPU doesn't support frequency scaling.

#### Intel Graphics Not Detected
**Check:**
```bash
lspci | grep -i vga
```
Script is designed for Intel integrated graphics (HD Graphics 520/530).

### Package Installation Issues

#### Intel Media Driver Installation Fails
```bash
# Check if package is available
apt search intel-media-va-driver

# Check system architecture
uname -m
```
Driver may not be available for all architectures/distributions.

#### Dependency Conflicts
Script checks dependencies before removal. If you encounter conflicts:
```bash
# Check what depends on a package
apt-cache rdepends intel-media-va-driver

# Force removal (use with caution)
sudo apt remove --purge intel-media-va-driver --force-depends
```

## Recovery Procedures

### Complete System Recovery
If something goes wrong:

1. **Check backups exist:**
   ```bash
   ls -la ~/.laptop_optimization_backups/
   ```

2. **Run revert script:**
   ```bash
   ./scripts/revert_optimizations.sh
   ```

3. **Manual recovery if needed:**
   ```bash
   # Restore GRUB
   sudo cp ~/.laptop_optimization_backups/grub_* /etc/default/grub
   sudo update-grub
   
   # Reset CPU governor
   echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   
   # Reset swappiness
   echo 60 | sudo tee /proc/sys/vm/swappiness
   ```

### Boot Issues
If system won't boot after GRUB changes:

1. **Boot from GRUB recovery:**
   - Select "Advanced options" in GRUB menu
   - Choose previous kernel version

2. **Edit GRUB at boot:**
   - Press 'e' at GRUB menu
   - Remove `i915.enable_guc=2` from kernel line
   - Press Ctrl+X to boot

3. **Restore GRUB configuration:**
   ```bash
   sudo cp ~/.laptop_optimization_backups/grub_TIMESTAMP /etc/default/grub
   sudo update-grub
   ```

## Diagnostic Commands

### System Information
```bash
# CPU information
lscpu | grep -E 'Model name|MHz|Core|Thread'

# Memory information
free -h

# Storage information
lsblk -f

# Graphics information
lspci | grep -i vga
glxinfo | grep -i vendor
```

### Current Optimization Status
```bash
# TRIM service
systemctl is-enabled fstrim.timer
systemctl is-active fstrim.timer

# CPU governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Swappiness
cat /proc/sys/vm/swappiness

# Custom services
systemctl is-enabled cpu-performance.service
```

## Log Analysis

### Benchmark Logs
Check `~/.laptop_benchmarks/` for performance data:
```bash
# List all benchmarks
ls -la ~/.laptop_benchmarks/

# View latest benchmark
cat ~/.laptop_benchmarks/benchmark_$(ls -t ~/.laptop_benchmarks/ | head -1)
```

### System Logs
```bash
# Check for systemd errors
journalctl -u fstrim.timer
journalctl -u cpu-performance.service

# Check for GRUB issues
journalctl -b | grep grub
```

## Getting Help

If you can't resolve the issue:

1. **Gather system information:**
   ```bash
   # Create diagnostic report
   {
     echo "=== System Information ==="
     uname -a
     lscpu | head -20
     free -h
     lsblk -f
     echo "=== Current Settings ==="
     cat /proc/sys/vm/swappiness
     cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A"
     systemctl is-enabled fstrim.timer 2>/dev/null || echo "N/A"
   } > diagnostic_report.txt
   ```

2. **Open a GitHub issue** with:
   - Diagnostic report
   - Error messages
   - Steps that led to the issue
   - Hardware details

3. **Check existing issues** for similar problems

## Prevention

- Always run benchmark script before optimizations
- Test on non-critical systems first
- Keep system backups independent of this tool
- Review script contents before running
- Don't run multiple optimization tools simultaneously