#!/bin/bash

# Dell Laptop Optimization Revert Script
# Reverts all optimizations made by optimize_laptop.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BACKUP_DIR="$HOME/.laptop_optimization_backups"

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

# Function to restore file from backup with verification
restore_file() {
    local target_file="$1"
    local backup_pattern="$2"
    
    # Find the most recent backup
    local backup_file=$(ls -t "$BACKUP_DIR"/"$backup_pattern"* 2>/dev/null | head -1)
    
    if [ -n "$backup_file" ] && [ -f "$backup_file" ]; then
        # Create temporary copy for validation
        local temp_file="/tmp/restore_temp_$(basename "$target_file")_$(date +%s)"
        if cp "$backup_file" "$temp_file"; then
            # Validate the backup file
            if [ -s "$temp_file" ]; then
                if sudo cp "$temp_file" "$target_file"; then
                    echo -e "${GREEN}✓ Restored $target_file from backup${NC}"
                    rm -f "$temp_file"
                    return 0
                else
                    echo -e "${RED}✗ Failed to restore $target_file${NC}"
                    rm -f "$temp_file"
                    return 1
                fi
            else
                echo -e "${RED}✗ Backup file is empty or invalid${NC}"
                rm -f "$temp_file"
                return 1
            fi
        else
            echo -e "${RED}✗ Cannot access backup file${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠ No backup found for $target_file${NC}"
        return 1
    fi
}

# Function to check package dependencies before removal
check_package_dependencies() {
    local package="$1"
    local dependents=$(apt-cache rdepends --installed "$package" 2>/dev/null | grep -v "Reverse Depends:" | head -5)
    
    if [ -n "$dependents" ]; then
        echo -e "${YELLOW}⚠ Warning: The following packages depend on $package:${NC}"
        echo "$dependents"
        echo -e "${YELLOW}Removing $package may affect these packages.${NC}"
        read -p "Continue with removal? (y/N):" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    return 0
}

# Function to get original swappiness value
get_original_swappiness() {
    local swappiness_file=$(ls -t "$BACKUP_DIR"/swappiness_original_* 2>/dev/null | head -1)
    if [ -f "$swappiness_file" ]; then
        grep "Original swappiness was:" "$swappiness_file" | cut -d: -f2 | xargs
    else
        echo "60"  # Default fallback
    fi
}

echo -e "${GREEN}=== Dell Laptop Optimization Revert Script ===${NC}"
echo "This script will revert optimizations made by optimize_laptop.sh"
echo "Backup directory: $BACKUP_DIR"
echo

if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}Error: Backup directory not found: $BACKUP_DIR${NC}"
    echo "Cannot proceed without backups."
    exit 1
fi

# 1. Disable TRIM service
if confirm "Disable TRIM service?"; then
    echo "Disabling TRIM service..."
    sudo systemctl disable fstrim.timer 2>/dev/null || true
    sudo systemctl stop fstrim.timer 2>/dev/null || true
    echo -e "${GREEN}✓ TRIM service disabled${NC}"
fi

# 2. Reset swappiness to default
if confirm "Reset swappiness to default?"; then
    echo "Resetting swappiness..."
    
    # Get the original swappiness value
    original_swappiness=$(get_original_swappiness)
    echo "Restoring swappiness to original value: $original_swappiness"
    
    if restore_file /etc/sysctl.conf sysctl.conf; then
        # Apply the restored settings
        if sudo sysctl -p; then
            echo -e "${GREEN}✓ Swappiness restored from backup${NC}"
        else
            echo -e "${YELLOW}⚠ sysctl.conf restored but failed to apply settings${NC}"
        fi
    else
        # Manual reset if no backup
        echo "No backup found, manually resetting..."
        sudo sed -i '/vm.swappiness/d' /etc/sysctl.conf
        if echo "$original_swappiness" | sudo tee /proc/sys/vm/swappiness > /dev/null; then
            # Verify the setting was applied
            current_swappiness=$(cat /proc/sys/vm/swappiness)
            if [ "$current_swappiness" = "$original_swappiness" ]; then
                echo -e "${GREEN}✓ Swappiness reset to $original_swappiness${NC}"
            else
                echo -e "${YELLOW}⚠ Swappiness may not have been set correctly${NC}"
            fi
        else
            echo -e "${RED}✗ Failed to reset swappiness${NC}"
        fi
    fi
fi

# 3. Remove Intel media driver
if confirm "Remove intel-media-va-driver?"; then
    echo "Checking Intel media driver dependencies..."
    
    if dpkg -l | grep -q intel-media-va-driver; then
        if check_package_dependencies intel-media-va-driver; then
            echo "Removing Intel media driver..."
            if sudo apt remove --purge -y intel-media-va-driver; then
                if sudo apt autoremove -y; then
                    echo -e "${GREEN}✓ Intel media driver removed${NC}"
                else
                    echo -e "${YELLOW}⚠ Driver removed but autoremove failed${NC}"
                fi
            else
                echo -e "${RED}✗ Failed to remove Intel media driver${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ Skipping Intel media driver removal due to dependencies${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Intel media driver not installed${NC}"
    fi
fi

# 4. Reset CPU governor to default
if confirm "Reset CPU governor to original settings?"; then
    echo "Resetting CPU governor..."
    
    # Disable our custom service
    if systemctl is-enabled cpu-performance.service &>/dev/null; then
        sudo systemctl disable cpu-performance.service 2>/dev/null || true
        echo -e "${GREEN}✓ Disabled cpu-performance service${NC}"
    fi
    
    if [ -f /etc/systemd/system/cpu-performance.service ]; then
        sudo rm -f /etc/systemd/system/cpu-performance.service
        echo -e "${GREEN}✓ Removed cpu-performance service file${NC}"
    fi
    
    sudo systemctl daemon-reload
    
    # Try to restore original governor settings
    governor_backup=$(ls -t "$BACKUP_DIR"/cpu_governors_* 2>/dev/null | head -1)
    cpu_count=0
    success_count=0
    
    if [ -f "$governor_backup" ]; then
        echo "Restoring original CPU governor settings..."
        while IFS=':' read -r cpu_path original_governor; do
            if [ -f "$cpu_path" ]; then
                cpu_count=$((cpu_count + 1))
                if echo "$original_governor" | sudo tee "$cpu_path" > /dev/null 2>&1; then
                    if [ "$(cat "$cpu_path")" = "$original_governor" ]; then
                        success_count=$((success_count + 1))
                    fi
                fi
            fi
        done < <(grep -v "^#" "$governor_backup")
    else
        echo "No backup found, setting to default governor..."
        # Set to ondemand (or powersave if ondemand not available)
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            if [ -f "$cpu" ]; then
                cpu_count=$((cpu_count + 1))
                target_governor="powersave"
                if grep -q "ondemand" /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null; then
                    target_governor="ondemand"
                fi
                
                if echo "$target_governor" | sudo tee "$cpu" > /dev/null 2>&1; then
                    if [ "$(cat "$cpu")" = "$target_governor" ]; then
                        success_count=$((success_count + 1))
                    fi
                fi
            fi
        done
    fi
    
    if [ "$success_count" -eq "$cpu_count" ] && [ "$cpu_count" -gt 0 ]; then
        echo -e "${GREEN}✓ CPU governor reset on $success_count/$cpu_count cores${NC}"
    else
        echo -e "${YELLOW}⚠ CPU governor reset on $success_count/$cpu_count cores${NC}"
    fi
fi

# 5. Remove Intel GPU kernel parameters
if confirm "Remove Intel GPU kernel parameters from GRUB?"; then
    echo "Removing Intel GPU kernel parameters..."
    
    if restore_file /etc/default/grub grub; then
        echo "Restoring GRUB from backup..."
        if sudo update-grub 2>/dev/null; then
            echo -e "${GREEN}✓ GRUB configuration restored from backup${NC}"
        else
            echo -e "${RED}✗ Failed to update GRUB after restore${NC}"
        fi
    else
        # Manual removal if no backup
        echo "No backup found, manually removing parameters..."
        
        # Create temporary file for safe editing
        temp_grub="/tmp/grub_revert_temp_$(date +%s)"
        cp /etc/default/grub "$temp_grub"
        
        # Remove i915.enable_guc parameter
        sed -i 's/i915\.enable_guc=[0-9]\+//g' "$temp_grub"
        sed -i 's/  \+/ /g' "$temp_grub"  # Clean up multiple spaces
        sed -i 's/ \+"/"/g' "$temp_grub"  # Clean up trailing spaces before quotes
        
        # Validate the modified file
        if grep -q "^GRUB_" "$temp_grub" && ! grep -q "i915.enable_guc" "$temp_grub"; then
            sudo cp "$temp_grub" /etc/default/grub
            rm -f "$temp_grub"
            
            if sudo update-grub 2>/dev/null; then
                echo -e "${GREEN}✓ Intel GPU parameters removed from GRUB${NC}"
            else
                echo -e "${RED}✗ Failed to update GRUB${NC}"
            fi
        else
            echo -e "${RED}✗ GRUB modification validation failed${NC}"
            rm -f "$temp_grub"
        fi
    fi
    
    echo -e "${YELLOW}⚠ Reboot required to activate GPU changes${NC}"
fi

# 6. Firefox revert instructions
if confirm "Show Firefox revert instructions?"; then
    echo -e "${YELLOW}=== Firefox Revert Instructions ===${NC}"
    echo "1. Open Firefox and type 'about:config' in address bar"
    echo "2. Search for 'browser.tabs.remote.autostart.maxContentParents'"
    echo "3. Right-click and select 'Reset' to restore default value"
    echo "4. Go to Settings > General > Performance"
    echo "5. Check 'Use recommended performance settings'"
    echo "6. This will restore default Firefox performance settings"
    echo -e "${GREEN}✓ Firefox revert instructions displayed${NC}"
fi

# 7. Clean up any remaining optimization artifacts
if confirm "Clean up temporary files and caches?"; then
    echo "Cleaning up..."
    
    # Clear systemd cache
    sudo systemctl daemon-reload
    
    # Clear package cache
    sudo apt autoclean
    
    echo -e "${GREEN}✓ Cleanup completed${NC}"
fi

# 8. Show current system status
echo -e "\n${GREEN}=== Revert Summary ===${NC}"
echo "✓ TRIM service: $(systemctl is-enabled fstrim.timer 2>/dev/null || echo 'disabled')"
echo "✓ Swappiness: $(cat /proc/sys/vm/swappiness)"
echo "✓ CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'unknown')"
echo "✓ Intel media driver: $(dpkg -l | grep -c intel-media-va-driver | sed 's/0/removed/;s/[^0]/still installed/')"

# Option to remove backup directory
if confirm "Remove backup directory ($BACKUP_DIR)?"; then
    rm -rf "$BACKUP_DIR"
    echo -e "${GREEN}✓ Backup directory removed${NC}"
else
    echo -e "${YELLOW}Backup directory preserved: $BACKUP_DIR${NC}"
fi

echo -e "\n${GREEN}Revert complete!${NC}"
echo -e "${YELLOW}Note: Some changes require a reboot to take full effect.${NC}"