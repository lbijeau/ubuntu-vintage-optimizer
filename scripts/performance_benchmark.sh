#!/bin/bash

# Performance Benchmark Script
# Captures baseline performance metrics before/after optimizations

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BENCHMARK_DIR="$HOME/.laptop_benchmarks"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="$BENCHMARK_DIR/benchmark_$TIMESTAMP.txt"

# Create benchmark directory
mkdir -p "$BENCHMARK_DIR"

echo -e "${GREEN}=== Dell Laptop Performance Benchmark ===${NC}"
echo "Results will be saved to: $RESULTS_FILE"
echo "Timestamp: $(date)"
echo

# Function to run a test and log results
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${BLUE}Running: $test_name${NC}"
    echo "=== $test_name ===" >> "$RESULTS_FILE"
    echo "Timestamp: $(date)" >> "$RESULTS_FILE"
    
    eval "$test_command" >> "$RESULTS_FILE" 2>&1
    echo "" >> "$RESULTS_FILE"
    
    echo -e "${GREEN}✓ $test_name completed${NC}"
}

# Start benchmarking
echo "Starting performance benchmark..." | tee "$RESULTS_FILE"
echo "System: $(uname -a)" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# 1. System Information
run_test "System Information" "
echo 'CPU Info:'
lscpu | grep -E 'Model name|CPU MHz|Cache|Core|Thread'
echo ''
echo 'Memory Info:'
free -h
echo ''
echo 'Storage Info:'
df -h /
lsblk -d -o name,size,model,rota | grep -v loop
echo ''
echo 'GPU Info:'
lspci | grep -E '(VGA|3D|Display)'
"

# 2. Current System Settings
run_test "Current Optimization Settings" "
echo 'CPU Governor:'
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'unknown'
echo ''
echo 'CPU Frequency:'
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null | head -4 || echo 'unknown'
echo ''
echo 'Swappiness:'
cat /proc/sys/vm/swappiness
echo ''
echo 'TRIM Service:'
systemctl is-enabled fstrim.timer 2>/dev/null || echo 'disabled'
echo ''
echo 'Intel Media Driver:'
dpkg -l | grep intel-media-va-driver || echo 'not installed'
"

# 3. CPU Performance Test
run_test "CPU Performance Test" "
echo 'Single-threaded CPU test (calculating pi):'
timeout 10s bash -c 'echo \"scale=3000; 4*a(1)\" | bc -l' 2>/dev/null | wc -c || echo 'Test completed'
echo ''
echo 'Multi-threaded CPU stress test (5 seconds):'
timeout 5s stress-ng --cpu 4 --metrics-brief 2>/dev/null || echo 'stress-ng not available - install with: sudo apt install stress-ng'
"

# 4. Memory Performance
run_test "Memory Performance" "
echo 'Memory bandwidth test:'
if command -v sysbench &> /dev/null; then
    sysbench memory --memory-total-size=1G run | grep -E '(events per second|total time)'
else
    echo 'sysbench not available - install with: sudo apt install sysbench'
    echo 'Memory usage:'
    cat /proc/meminfo | grep -E '(MemTotal|MemFree|MemAvailable|Cached|SwapTotal|SwapFree)'
fi
"

# 5. Disk Performance
run_test "Disk Performance" "
echo 'Disk I/O test (1GB file):'
echo 'Write test:'
sync && time dd if=/dev/zero of=/tmp/benchmark_test bs=1M count=1024 conv=fdatasync 2>&1 | grep -E '(real|copied)'
echo 'Read test:'
sync && echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
time dd if=/tmp/benchmark_test of=/dev/null bs=1M 2>&1 | grep -E '(real|copied)'
rm -f /tmp/benchmark_test
echo ''
echo 'I/O stats:'
iostat -x 1 3 | tail -10 || echo 'iostat not available - install with: sudo apt install sysstat'
"

# 6. Graphics Performance (basic)
run_test "Graphics Performance" "
echo 'OpenGL info:'
glxinfo | grep -E '(OpenGL version|OpenGL renderer|OpenGL vendor)' 2>/dev/null || echo 'glxinfo not available - install with: sudo apt install mesa-utils'
echo ''
echo 'Video decode capabilities:'
vainfo 2>/dev/null | grep -A20 'VAProfile' || echo 'vainfo not available - install with: sudo apt install vainfo'
"

# 7. Network Performance (basic)
run_test "Network Performance" "
echo 'Network interfaces:'
ip -br addr show
echo ''
echo 'Network speed test to localhost:'
timeout 5s iperf3 -c localhost -t 3 2>/dev/null | grep -E '(sender|receiver)' || echo 'iperf3 not available or no server running'
"

# 8. Boot Time and System Responsiveness
run_test "System Performance Metrics" "
echo 'Boot time:'
systemd-analyze || echo 'systemd-analyze not available'
echo ''
echo 'System load:'
uptime
echo ''
echo 'Top CPU processes:'
ps aux --sort=-%cpu | head -10
echo ''
echo 'Top memory processes:'
ps aux --sort=-%mem | head -10
"

# 9. Battery Performance (if laptop)
run_test "Power Management" "
echo 'Power consumption:'
cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo 'No battery detected'
cat /sys/class/power_supply/BAT*/status 2>/dev/null || echo 'No battery status'
echo ''
echo 'CPU frequency scaling:'
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_* 2>/dev/null | head -10
"

# 10. Firefox/Browser Performance Test
run_test "Browser Performance Test" "
echo 'Current Firefox processes:'
ps aux | grep firefox | grep -v grep | wc -l
echo ''
echo 'Firefox memory usage:'
ps aux | grep firefox | grep -v grep | awk '{sum += \$6} END {print \"Total Firefox RAM: \" sum/1024 \" MB\"}'
echo ''
echo 'Browser GPU acceleration check:'
glxinfo | grep -i 'hardware' 2>/dev/null || echo 'No hardware acceleration info available'
"

# Summary
echo "" >> "$RESULTS_FILE"
echo "=== BENCHMARK SUMMARY ===" >> "$RESULTS_FILE"
echo "Benchmark completed at: $(date)" >> "$RESULTS_FILE"
echo "Results saved to: $RESULTS_FILE" >> "$RESULTS_FILE"

echo -e "\n${GREEN}=== Benchmark Complete ===${NC}"
echo "Results saved to: $RESULTS_FILE"
echo
echo -e "${YELLOW}Quick Summary:${NC}"
echo "CPU: $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo "RAM: $(free -h | grep Mem | awk '{print $2}')"
echo "Storage: $(df -h / | tail -1 | awk '{print $2}')"
echo "CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'unknown')"
echo "Swappiness: $(cat /proc/sys/vm/swappiness)"

echo -e "\n${BLUE}To compare results after optimization:${NC}"
echo "1. Run this script now (baseline): ./performance_benchmark.sh"
echo "2. Run optimization script: ./optimize_laptop.sh"
echo "3. Run this script again (optimized): ./performance_benchmark.sh"
echo "4. Compare the two result files in $BENCHMARK_DIR"

echo -e "\n${YELLOW}Recommended additional tools to install for more comprehensive testing:${NC}"
echo "sudo apt install stress-ng sysbench sysstat mesa-utils vainfo iperf3"