# Supported Hardware

This document outlines the hardware configurations that have been tested with the Laptop Optimizer toolkit.

## Fully Tested Hardware

### Dell Latitude Series
- **Dell Latitude E7450**
  - CPU: Intel i5-6300U (Skylake, 6th gen)
  - RAM: 16GB/32GB DDR3L
  - Storage: 256GB/512GB SSD
  - Graphics: Intel HD Graphics 520
  - Status: ✅ Fully supported and tested

## Expected Compatible Hardware

### CPU Requirements
- **Intel 6th Generation (Skylake) and newer**
  - i3/i5/i7 series
  - Supports CPU frequency scaling
  - Integrated graphics preferred

### Memory Requirements
- **Minimum: 8GB RAM**
  - Swappiness optimizations most beneficial with 16GB+
  - 32GB+ provides best results

### Storage Requirements
- **SSD strongly recommended**
  - TRIM optimizations require SSD
  - Script detects storage type automatically
  - HDDs will skip SSD-specific optimizations

### Graphics Requirements
- **Intel Integrated Graphics**
  - HD Graphics 520/530 (6th gen)
  - UHD Graphics 620/630 (7th/8th gen)
  - Iris series
  - AMD/NVIDIA discrete graphics: Limited support

## Manufacturer Compatibility

### Dell (Primary Support)
- **Latitude Series:** E7450, E7470, 7480, 7490
- **Inspiron Series:** Should work on modern models
- **XPS Series:** Should work with Intel graphics
- **Precision Series:** Mobile workstations (limited testing)

### Lenovo (Expected Compatible)
- **ThinkPad Series:** T460, T470, T480, X1 Carbon
- **IdeaPad Series:** Modern models with Intel CPUs
- **Yoga Series:** 2-in-1 models

### HP (Expected Compatible)
- **EliteBook Series:** 840, 850 G3/G4/G5
- **ProBook Series:** 450, 650 series
- **Pavilion Series:** Consumer laptops

### Other Manufacturers
- **ASUS:** ZenBook, VivoBook series
- **Acer:** Aspire, Swift series
- **MSI:** Modern/Prestige series (non-gaming)

## Operating System Support

### Fully Supported
- **Ubuntu 20.04 LTS and newer**
- **Debian 11 (Bullseye) and newer**
- **Linux Mint 20+ (Ubuntu-based)**

### Expected Compatible
- **Pop!_OS**
- **Elementary OS**
- **Zorin OS**
- **KDE Neon**

### Limited Support
- **Fedora:** Different package management, may need modifications
- **openSUSE:** Different package management
- **Arch Linux:** Rolling release, frequent changes

## Hardware Detection Logic

The scripts include hardware detection for:

```bash
# CPU Architecture Detection
CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
CPU_FAMILY=$(lscpu | grep "CPU family" | awk '{print $3}')

# Graphics Detection  
GPU_INFO=$(lspci | grep -i vga)

# Storage Type Detection
STORAGE_TYPE=$(lsblk -d -o name,rota | grep -v NAME)
```

## Known Limitations

### Unsupported Hardware
- **AMD CPUs:** Limited governor support
- **Very old hardware:** Pre-2015 laptops
- **ARM processors:** Different architecture
- **Chromebooks:** ChromeOS restrictions

### Partial Support
- **Gaming Laptops:** May have custom power management
- **Workstations:** Different optimization priorities
- **Hybrid Graphics:** NVIDIA Optimus complexity

## Testing Your Hardware

Before running optimizations:

1. **Check CPU compatibility:**
   ```bash
   # Check if frequency scaling is available
   ls /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   
   # Check available governors
   cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
   ```

2. **Check graphics support:**
   ```bash
   # Identify graphics hardware
   lspci | grep -i vga
   
   # Check for Intel graphics
   lspci | grep -i "intel.*graphics"
   ```

3. **Check storage type:**
   ```bash
   # Check if SSD (ROTA=0 means SSD)
   lsblk -d -o name,rota
   ```

4. **Run benchmark first:**
   ```bash
   ./scripts/performance_benchmark.sh
   ```

## Reporting Compatibility

If you test on new hardware, please report results:

### Successful Testing
Create an issue with:
- Hardware specifications
- OS version and kernel
- Benchmark results (before/after)
- Any issues encountered

### Hardware Not Working
Report with:
- Full hardware specifications
- Error messages
- System logs
- Output of diagnostic commands

## Future Hardware Support

### Planned Additions
- **AMD Ryzen Support:** CPU governor optimizations
- **ARM64 Support:** Apple Silicon, Raspberry Pi
- **Advanced GPU Support:** NVIDIA/AMD discrete graphics

### Community Contributions
We welcome hardware compatibility contributions:
- Test scripts on your hardware
- Submit compatibility reports
- Contribute hardware-specific optimizations
- Update documentation

## Compatibility Matrix

| Component | Requirement | Status | Notes |
|-----------|-------------|---------|-------|
| CPU | Intel 6th gen+ | ✅ Tested | Frequency scaling required |
| CPU | AMD Ryzen | ⚠️ Limited | Governor support varies |
| GPU | Intel integrated | ✅ Tested | HD/UHD Graphics series |
| GPU | AMD/NVIDIA | ⚠️ Partial | Basic optimizations only |
| RAM | 8GB+ | ✅ Required | 16GB+ recommended |
| Storage | SSD | ✅ Preferred | HDD works with limitations |
| OS | Ubuntu/Debian | ✅ Tested | systemd required |
| OS | Other Linux | ⚠️ Varies | Package management differences |

**Legend:**
- ✅ Fully supported and tested
- ⚠️ Partial support or untested
- ❌ Not supported

## Hardware-Specific Notes

### Dell Latitude E7450
- Excellent compatibility
- All optimizations work as expected
- No known issues
- Thermal management works well

### ThinkPad Series
- Generally compatible
- May have different key combinations
- Custom power management profiles
- BIOS settings may affect results

### Gaming Laptops
- Performance mode may override optimizations
- Custom cooling solutions
- Multiple GPU configurations
- Proceed with caution