#!/bin/bash

# Dell Laptop Optimization Script
# Creates backups and applies optimizations with user confirmation

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BACKUP_DIR="$HOME/.laptop_optimization_backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

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

# Function to create backup directory
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        echo -e "${GREEN}Created backup directory: $BACKUP_DIR${NC}"
    fi
}

# Function to backup file with verification
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup_path="$BACKUP_DIR/$(basename $file)_$TIMESTAMP"
        if cp "$file" "$backup_path" && [ -f "$backup_path" ]; then
            echo -e "${GREEN}✓ Backed up: $file${NC}"
            return 0
        else
            echo -e "${RED}✗ Failed to backup: $file${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠ File not found for backup: $file${NC}"
        return 1
    fi
}

# Function to check available disk space
check_disk_space() {
    local required_mb=100  # Minimum 100MB required
    local available_kb=$(df "$BACKUP_DIR" | tail -1 | awk '{print $4}')
    local available_mb=$((available_kb / 1024))
    
    if [ "$available_mb" -lt "$required_mb" ]; then
        echo -e "${RED}Error: Insufficient disk space. Need ${required_mb}MB, have ${available_mb}MB${NC}"
        return 1
    fi
    return 0
}

# Function to verify service status
verify_service() {
    local service="$1"
    local expected_state="$2"
    local actual_state=$(systemctl is-enabled "$service" 2>/dev/null || echo "disabled")
    
    if [ "$actual_state" = "$expected_state" ]; then
        echo -e "${GREEN}✓ Service $service is $expected_state${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Service $service state: $actual_state (expected: $expected_state)${NC}"
        return 1
    fi
}

echo -e "${GREEN}=== Dell Laptop Optimization Script ===${NC}"
echo "This script will optimize your laptop performance with confirmation at each step."
echo "Backups will be created in: $BACKUP_DIR"
echo

create_backup_dir

# Check disk space before proceeding
if ! check_disk_space; then
    echo -e "${RED}Aborting due to insufficient disk space${NC}"
    exit 1
fi

# 1. Enable TRIM for SSD
if confirm "Enable TRIM service for SSD optimization?"; then
    echo "Enabling TRIM service..."
    if sudo systemctl enable fstrim.timer && sudo systemctl start fstrim.timer; then
        verify_service fstrim.timer enabled
        if systemctl is-active fstrim.timer &>/dev/null; then
            echo -e "${GREEN}✓ TRIM service enabled and running${NC}"
        else
            echo -e "${YELLOW}⚠ TRIM service enabled but not active${NC}"
        fi
    else
        echo -e "${RED}✗ Failed to enable TRIM service${NC}"
    fi
fi

# 2. Configure swappiness
if confirm "Set vm.swappiness=10 to reduce swap usage with your 32GB RAM?"; then
    echo "Configuring swappiness..."
    
    if backup_file /etc/sysctl.conf; then
        # Store current swappiness value
        current_swappiness=$(cat /proc/sys/vm/swappiness)
        echo "# Original swappiness was: $current_swappiness" >> "$BACKUP_DIR/swappiness_original_$TIMESTAMP"
        
        # Remove existing swappiness setting if it exists
        sudo sed -i '/vm.swappiness/d' /etc/sysctl.conf
        
        # Add new swappiness setting
        echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf > /dev/null
        
        # Apply immediately and verify
        if echo 10 | sudo tee /proc/sys/vm/swappiness > /dev/null; then
            new_swappiness=$(cat /proc/sys/vm/swappiness)
            if [ "$new_swappiness" = "10" ]; then
                echo -e "${GREEN}✓ Swappiness set to 10${NC}"
            else
                echo -e "${YELLOW}⚠ Swappiness setting may not have applied correctly${NC}"
            fi
        else
            echo -e "${RED}✗ Failed to apply swappiness setting${NC}"
        fi
    else
        echo -e "${RED}✗ Failed to backup sysctl.conf, skipping swappiness configuration${NC}"
    fi
fi

# 3. Install Intel media driver for hardware acceleration
if confirm "Install intel-media-va-driver for better video performance?"; then
    echo "Installing Intel media driver..."
    sudo apt update
    sudo apt install -y intel-media-va-driver
    echo -e "${GREEN}✓ Intel media driver installed${NC}"
fi

# 4. Configure CPU governor for performance
if confirm "Set CPU governor to performance mode?"; then
    echo "Setting CPU governor to performance..."
    
    # Store current governor settings
    echo "# CPU Governor backup - $(date)" > "$BACKUP_DIR/cpu_governors_$TIMESTAMP"
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [ -f "$cpu" ]; then
            echo "$cpu:$(cat $cpu)" >> "$BACKUP_DIR/cpu_governors_$TIMESTAMP"
        fi
    done
    
    # Install cpufrequtils if not present
    if ! command -v cpufreq-set &> /dev/null; then
        echo "Installing cpufrequtils..."
        sudo apt update && sudo apt install -y cpufrequtils
    fi
    
    # Set all CPUs to performance with error checking
    local cpu_count=0
    local success_count=0
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [ -f "$cpu" ]; then
            cpu_count=$((cpu_count + 1))
            if echo performance | sudo tee "$cpu" > /dev/null 2>&1; then
                # Verify the setting was applied
                if [ "$(cat $cpu)" = "performance" ]; then
                    success_count=$((success_count + 1))
                fi
            fi
        fi
    done
    
    if [ "$success_count" -eq "$cpu_count" ] && [ "$cpu_count" -gt 0 ]; then
        echo -e "${GREEN}✓ CPU governor set to performance on $success_count/$cpu_count cores${NC}"
        
        # Make it persistent by creating a service
        if sudo tee /etc/systemd/system/cpu-performance.service > /dev/null << EOF
[Unit]
Description=Set CPU Governor to Performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do [ -f "\$cpu" ] && echo performance > "\$cpu" 2>/dev/null || true; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
        then
            if sudo systemctl enable cpu-performance.service; then
                verify_service cpu-performance.service enabled
            else
                echo -e "${YELLOW}⚠ Service created but failed to enable${NC}"
            fi
        else
            echo -e "${RED}✗ Failed to create systemd service${NC}"
        fi
    else
        echo -e "${RED}✗ Failed to set CPU governor on some cores ($success_count/$cpu_count)${NC}"
    fi
fi

# 5. Add Intel GPU optimization kernel parameters
if confirm "Add Intel GPU optimization kernel parameters (i915.enable_guc=2)?"; then
    echo "Configuring Intel GPU kernel parameters..."
    
    if backup_file /etc/default/grub; then
        # Validate GRUB file before modification
        if ! grep -q "^GRUB_" /etc/default/grub; then
            echo -e "${RED}✗ Invalid GRUB configuration file${NC}"
            continue
        fi
        
        # Create a temporary file for safe editing
        local temp_grub="/tmp/grub_temp_$TIMESTAMP"
        cp /etc/default/grub "$temp_grub"
        
        # Remove existing i915.enable_guc parameter if present
        sed -i 's/i915\.enable_guc=[0-9]\+//g' "$temp_grub"
        sed -i 's/  \+/ /g' "$temp_grub"  # Clean up multiple spaces
        
        # Add the parameter safely
        if grep -q "^GRUB_CMDLINE_LINUX_DEFAULT=" "$temp_grub"; then
            # Modify existing line
            sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/s/"$/ i915.enable_guc=2"/' "$temp_grub"
        else
            # Add new line
            echo 'GRUB_CMDLINE_LINUX_DEFAULT="i915.enable_guc=2"' >> "$temp_grub"
        fi
        
        # Validate the modified file
        if grep -q "i915.enable_guc=2" "$temp_grub" && grep -q "^GRUB_" "$temp_grub"; then
            # Apply the changes
            sudo cp "$temp_grub" /etc/default/grub
            rm -f "$temp_grub"
            
            # Update GRUB with error checking
            if sudo update-grub 2>/dev/null; then
                echo -e "${GREEN}✓ Intel GPU kernel parameters added${NC}"
                echo -e "${YELLOW}⚠ Reboot required to activate GPU optimizations${NC}"
            else
                echo -e "${RED}✗ Failed to update GRUB - restoring backup${NC}"
                # Restore backup on failure
                local backup_grub=$(ls -t "$BACKUP_DIR"/grub_* 2>/dev/null | head -1)
                if [ -n "$backup_grub" ]; then
                    sudo cp "$backup_grub" /etc/default/grub
                    sudo update-grub
                fi
            fi
        else
            echo -e "${RED}✗ GRUB modification validation failed${NC}"
            rm -f "$temp_grub"
        fi
    else
        echo -e "${RED}✗ Failed to backup GRUB configuration, skipping${NC}"
    fi
fi

# 6. Firefox optimization suggestions
if confirm "Show Firefox optimization instructions (manual steps)?"; then
    echo -e "${YELLOW}=== Firefox Optimization Instructions ===${NC}"
    echo "1. Open Firefox and type 'about:config' in address bar"
    echo "2. Search for 'browser.tabs.remote.autostart.maxContentParents'"
    echo "3. Set value to 4 (reduces memory usage)"
    echo "4. Go to Settings > General > Performance"
    echo "5. Uncheck 'Use recommended performance settings'"
    echo "6. Check 'Use hardware acceleration when available'"
    echo "7. Set 'Content process limit' to 4"
    echo -e "${GREEN}✓ Firefox optimization instructions displayed${NC}"
fi

# 7. Show current optimizations status
echo -e "\n${GREEN}=== Optimization Summary ===${NC}"
echo "✓ TRIM service: $(systemctl is-enabled fstrim.timer 2>/dev/null || echo 'disabled')"
echo "✓ Swappiness: $(cat /proc/sys/vm/swappiness)"
echo "✓ CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'unknown')"
echo "✓ Intel media driver: $(dpkg -l | grep intel-media-va-driver | wc -l | sed 's/0/not installed/;s/[^0]/installed/')"

echo -e "\n${GREEN}Optimization complete!${NC}"
echo -e "${YELLOW}Note: Some optimizations require a reboot to take full effect.${NC}"
echo "Backups saved in: $BACKUP_DIR"