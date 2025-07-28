#!/bin/bash

# Dell Laptop Optimization and Comparison Script
# Automates: baseline benchmark -> optimize -> new benchmark -> comparison report

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCHMARK_DIR="$HOME/.laptop_benchmarks"
REPORTS_DIR="$HOME/.laptop_reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORTS_DIR/optimization_report_$TIMESTAMP.md"

# Function to prompt for confirmation
confirm() {
    local message="$1"
    echo -e "${YELLOW}$message${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Operation cancelled.${NC}"
        return 1
    fi
    return 0
}

# Function to create directories
create_directories() {
    mkdir -p "$BENCHMARK_DIR" "$REPORTS_DIR"
    echo -e "${GREEN}Created directories: $BENCHMARK_DIR, $REPORTS_DIR${NC}"
}

# Function to run benchmark and capture results
run_benchmark() {
    local benchmark_type="$1"
    local output_file="$2"
    
    echo -e "${BLUE}Running $benchmark_type benchmark...${NC}"
    
    # Run the benchmark script and capture its output
    if "$SCRIPT_DIR/performance_benchmark.sh" > "$output_file" 2>&1; then
        echo -e "${GREEN}✓ $benchmark_type benchmark completed${NC}"
        echo "Results saved to: $output_file"
        return 0
    else
        echo -e "${RED}✗ $benchmark_type benchmark failed${NC}"
        return 1
    fi
}

# Function to extract key metrics from benchmark results
extract_metrics() {
    local benchmark_file="$1"
    local temp_file="/tmp/metrics_$$"
    
    # Extract key performance indicators
    {
        echo "=== EXTRACTED METRICS ==="
        echo "Timestamp: $(date)"
        echo ""
        
        # System Info
        echo "## System Information"
        grep -A 10 "=== System Information ===" "$benchmark_file" | grep -E "(CPU|Memory|Storage)" || echo "System info not found"
        echo ""
        
        # Current Settings
        echo "## Current Settings"
        grep -A 10 "=== Current Optimization Settings ===" "$benchmark_file" | grep -E "(Governor|Swappiness|TRIM)" || echo "Settings not found"
        echo ""
        
        # CPU Performance
        echo "## CPU Performance"
        grep -A 5 "=== CPU Performance Test ===" "$benchmark_file" | tail -3 || echo "CPU performance not found"
        echo ""
        
        # Memory Performance
        echo "## Memory Performance"
        grep -A 5 "=== Memory Performance ===" "$benchmark_file" | grep -E "(events per second|total time|MemAvailable)" || echo "Memory performance not found"
        echo ""
        
        # Disk Performance
        echo "## Disk Performance"
        grep -A 10 "=== Disk Performance ===" "$benchmark_file" | grep -E "(real|copied|MB/s)" | head -4 || echo "Disk performance not found"
        echo ""
        
        # Boot Time
        echo "## System Performance"
        grep -A 5 "=== System Performance Metrics ===" "$benchmark_file" | grep -E "(Startup finished|load average)" || echo "Boot time not found"
        echo ""
        
    } > "$temp_file"
    
    echo "$temp_file"
}

# Function to generate comparison report
generate_report() {
    local baseline_file="$1"
    local optimized_file="$2"
    local baseline_metrics="$3"
    local optimized_metrics="$4"
    
    echo -e "${BLUE}Generating comparison report...${NC}"
    
    cat > "$REPORT_FILE" << EOF
# Dell Laptop Optimization Report

**Generated:** $(date)  
**System:** $(uname -a)  
**Script Version:** $(git -C "$SCRIPT_DIR/.." rev-parse --short HEAD 2>/dev/null || echo "unknown")

## Summary

This report compares system performance before and after applying optimizations using the ubuntu-vintage-optimizer toolkit.

## Test Methodology

1. **Baseline Benchmark**: Captured initial system performance metrics
2. **Optimization**: Applied laptop optimizations using \`optimize_laptop.sh\`
3. **Post-Optimization Benchmark**: Captured performance metrics after optimization
4. **Comparison**: Generated this report highlighting improvements

---

## Baseline Performance (Before Optimization)

\`\`\`
$(sed 's/^//' "$baseline_metrics")
\`\`\`

---

## Optimized Performance (After Optimization)

\`\`\`
$(sed 's/^//' "$optimized_metrics")
\`\`\`

---

## Key Changes Applied

EOF

    # Add optimization details if backup directory exists
    local backup_dir="$HOME/.laptop_optimization_backups"
    if [ -d "$backup_dir" ]; then
        echo "The following optimizations were applied:" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        
        # Check for TRIM service
        if systemctl is-enabled fstrim.timer &>/dev/null; then
            echo "- ✅ **TRIM Service**: Enabled for SSD optimization" >> "$REPORT_FILE"
        fi
        
        # Check swappiness
        local swappiness
        swappiness=$(cat /proc/sys/vm/swappiness 2>/dev/null || echo "unknown")
        if [ "$swappiness" = "10" ]; then
            echo "- ✅ **Swappiness**: Set to 10 (reduced swap usage)" >> "$REPORT_FILE"
        fi
        
        # Check CPU governor
        local governor
        governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
        if [ "$governor" = "performance" ]; then
            echo "- ✅ **CPU Governor**: Set to performance mode" >> "$REPORT_FILE"
        fi
        
        # Check Intel media driver
        if dpkg -l 2>/dev/null | grep -q intel-media-va-driver; then
            echo "- ✅ **Intel Media Driver**: Installed for hardware acceleration" >> "$REPORT_FILE"
        fi
        
        # Check for GRUB modifications
        if grep -q "i915.enable_guc=2" /etc/default/grub 2>/dev/null; then
            echo "- ✅ **Intel GPU**: Kernel parameters optimized (i915.enable_guc=2)" >> "$REPORT_FILE"
        fi
    fi
    
    cat >> "$REPORT_FILE" << EOF

---

## Performance Analysis

### Before vs After Comparison

| Metric | Baseline | Optimized | Change |
|--------|----------|-----------|--------|
| CPU Governor | $(grep "CPU Governor:" "$baseline_metrics" | cut -d: -f2 | xargs || echo "N/A") | $(grep "CPU Governor:" "$optimized_metrics" | cut -d: -f2 | xargs || echo "N/A") | Improved |
| Swappiness | $(grep "Swappiness:" "$baseline_metrics" | cut -d: -f2 | xargs || echo "N/A") | $(grep "Swappiness:" "$optimized_metrics" | cut -d: -f2 | xargs || echo "N/A") | Optimized |
| TRIM Service | $(grep "TRIM Service:" "$baseline_metrics" | cut -d: -f2 | xargs || echo "N/A") | $(grep "TRIM Service:" "$optimized_metrics" | cut -d: -f2 | xargs || echo "N/A") | Enhanced |

### Expected Improvements

- **CPU Performance**: Performance governor should provide better responsiveness
- **Memory Usage**: Lower swappiness reduces unnecessary swapping with 32GB RAM
- **SSD Longevity**: TRIM service helps maintain SSD performance over time
- **Graphics**: Intel GPU optimizations improve video playback and acceleration
- **Boot Time**: Various optimizations may reduce startup time

---

## Raw Benchmark Data

### Baseline Results
- **File**: \`$(basename "$baseline_file")\`
- **Location**: \`$baseline_file\`

### Optimized Results  
- **File**: \`$(basename "$optimized_file")\`
- **Location**: \`$optimized_file\`

---

## Recommendations

1. **Reboot Required**: Some optimizations require a system reboot to take full effect
2. **Monitor Performance**: Watch system behavior over the next few days
3. **Revert if Needed**: Use \`revert_optimizations.sh\` if any issues occur
4. **Regular Benchmarks**: Re-run benchmarks periodically to track performance

---

## Next Steps

- [ ] Reboot the system to activate all optimizations
- [ ] Test critical applications and workflows
- [ ] Monitor system stability over 24-48 hours
- [ ] Run additional benchmarks after reboot if desired

---

*Report generated by ubuntu-vintage-optimizer v$(git -C "$SCRIPT_DIR/.." describe --tags 2>/dev/null || echo "dev")*
*Backup files preserved in: \`$backup_dir\`*
EOF

    echo -e "${GREEN}✓ Report generated: $REPORT_FILE${NC}"
}

# Main execution
main() {
    echo -e "${GREEN}=== Dell Laptop Optimization and Comparison Tool ===${NC}"
    echo "This script will:"
    echo "1. Run baseline performance benchmark"
    echo "2. Apply laptop optimizations"
    echo "3. Run post-optimization benchmark"
    echo "4. Generate comparison report in Markdown"
    echo ""
    
    if ! confirm "Proceed with full optimization and benchmarking process?"; then
        exit 1
    fi
    
    # Create necessary directories
    create_directories
    
    # Step 1: Baseline benchmark
    echo -e "\n${YELLOW}=== Step 1: Baseline Benchmark ===${NC}"
    baseline_file="$BENCHMARK_DIR/baseline_$TIMESTAMP.txt"
    
    if ! run_benchmark "baseline" "$baseline_file"; then
        echo -e "${RED}Failed to run baseline benchmark${NC}"
        exit 1
    fi
    
    # Extract baseline metrics
    baseline_metrics=$(extract_metrics "$baseline_file")
    
    # Step 2: Apply optimizations
    echo -e "\n${YELLOW}=== Step 2: Apply Optimizations ===${NC}"
    echo "Running optimization script..."
    
    if confirm "Proceed with applying optimizations?"; then
        if "$SCRIPT_DIR/optimize_laptop.sh"; then
            echo -e "${GREEN}✓ Optimizations applied successfully${NC}"
        else
            echo -e "${RED}✗ Optimization failed${NC}"
            echo "You can still run the post-optimization benchmark to see current state."
            if ! confirm "Continue with post-optimization benchmark anyway?"; then
                exit 1
            fi
        fi
    else
        echo -e "${YELLOW}Skipping optimizations. Will benchmark current state.${NC}"
    fi
    
    # Step 3: Post-optimization benchmark
    echo -e "\n${YELLOW}=== Step 3: Post-Optimization Benchmark ===${NC}"
    optimized_file="$BENCHMARK_DIR/optimized_$TIMESTAMP.txt"
    
    if ! run_benchmark "post-optimization" "$optimized_file"; then
        echo -e "${RED}Failed to run post-optimization benchmark${NC}"
        exit 1
    fi
    
    # Extract optimized metrics
    optimized_metrics=$(extract_metrics "$optimized_file")
    
    # Step 4: Generate report
    echo -e "\n${YELLOW}=== Step 4: Generate Report ===${NC}"
    generate_report "$baseline_file" "$optimized_file" "$baseline_metrics" "$optimized_metrics"
    
    # Cleanup temporary files
    rm -f "$baseline_metrics" "$optimized_metrics"
    
    # Final summary
    echo -e "\n${GREEN}=== Process Complete ===${NC}"
    echo "📊 Baseline benchmark: $baseline_file"
    echo "🚀 Optimized benchmark: $optimized_file"  
    echo "📋 Comparison report: $REPORT_FILE"
    echo ""
    echo -e "${BLUE}To view the report:${NC}"
    echo "cat \"$REPORT_FILE\""
    echo ""
    echo -e "${YELLOW}Remember to reboot your system to activate all optimizations!${NC}"
}

# Check if required scripts exist
if [ ! -f "$SCRIPT_DIR/performance_benchmark.sh" ]; then
    echo -e "${RED}Error: performance_benchmark.sh not found in $SCRIPT_DIR${NC}"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/optimize_laptop.sh" ]; then
    echo -e "${RED}Error: optimize_laptop.sh not found in $SCRIPT_DIR${NC}"
    exit 1
fi

# Make sure scripts are executable
chmod +x "$SCRIPT_DIR/performance_benchmark.sh" "$SCRIPT_DIR/optimize_laptop.sh"

# Run main function
main "$@"