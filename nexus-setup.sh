#!/bin/bash
# Nexus Network Auto Setup Script
# GitHub: https://github.com/YOUR_USERNAME/YOUR_REPO

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Nexus Network Setup Script${NC}"
echo -e "${GREEN}================================${NC}\n"

# Update and install dependencies
echo -e "${YELLOW}[1/6] Updating system and installing dependencies...${NC}"
apt update
apt install build-essential pkg-config libssl-dev git curl screen -y

# Install Rust
echo -e "${YELLOW}[2/6] Installing Rust...${NC}"
curl https://sh.rustup.rs -sSf | sh -s -- -y
source /root/.cargo/env

# Clone repository
echo -e "${YELLOW}[3/6] Cloning Nexus CLI repository...${NC}"
cd /root
if [ -d "/root/nexus-cli" ]; then
    echo -e "${YELLOW}Repository already exists. Pulling latest changes...${NC}"
    cd /root/nexus-cli
    git pull
else
    git clone https://github.com/nexus-xyz/nexus-cli
fi

# Apply patches
echo -e "${YELLOW}[4/6] Applying patches...${NC}"
cd /root/nexus-cli/clients/cli
sed -i 's/0.75/1.0/g' src/session/setup.rs
sed -i 's/4294967296/1073741824/' src/consts.rs

# Build
echo -e "${YELLOW}[5/6] Building Nexus CLI (this may take a few minutes)...${NC}"
cargo build --release

# Get user input
echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}Configuration${NC}"
echo -e "${GREEN}================================${NC}\n"

# Node ID input
read -p "Node ID: Enter your Node ID: " NODE_ID
while [[ ! "$NODE_ID" =~ ^[0-9]+$ ]]; do
    echo -e "${RED}Invalid Node ID. Please enter a numeric value.${NC}"
    read -p "Node ID: Enter your Node ID: " NODE_ID
done

# Max Threads input
read -p "Max Threads: Enter number of threads: " MAX_THREADS
while [[ ! "$MAX_THREADS" =~ ^[0-9]+$ ]] || [ "$MAX_THREADS" -lt 1 ]; do
    echo -e "${RED}Invalid thread count. Please enter a positive number.${NC}"
    read -p "Max Threads: Enter number of threads: " MAX_THREADS
done

# Max Difficulty selection
echo -e "\nMax Difficulty: Select model"
echo "1) extra_large_5"
echo "2) extra_large_4"
echo "3) extra_large_2"
echo "4) extra_large"
echo "5) large"
echo "6) medium"

while true; do
    read -p "Choose (1-6): " DIFFICULTY_CHOICE
    case $DIFFICULTY_CHOICE in
        1)
            MAX_DIFFICULTY="extra_large_5"
            break
            ;;
        2)
            MAX_DIFFICULTY="extra_large_4"
            break
            ;;
        3)
            MAX_DIFFICULTY="extra_large_2"
            break
            ;;
        4)
            MAX_DIFFICULTY="extra_large"
            break
            ;;
        5)
            MAX_DIFFICULTY="large"
            break
            ;;
        6)
            MAX_DIFFICULTY="medium"
            break
            ;;
        *)
            echo -e "${RED}Invalid choice. Please select 1-6.${NC}"
            ;;
    esac
done

# Display configuration
echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}Configuration Summary${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "Node ID: ${YELLOW}$NODE_ID${NC}"
echo -e "Max Threads: ${YELLOW}$MAX_THREADS${NC}"
echo -e "Max Difficulty: ${YELLOW}$MAX_DIFFICULTY${NC}"
echo -e "${GREEN}================================${NC}\n"

# Confirm before starting
read -p "Start Nexus Network? (y/n): " CONFIRM
if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo -e "${YELLOW}Cancelled.${NC}"
    exit 0
fi

# Start Nexus Network
echo -e "\n${YELLOW}[6/6] Starting Nexus Network in screen session...${NC}\n"
screen -dmS nexus /root/nexus-cli/clients/cli/target/release/nexus-network start --node-id $NODE_ID --max-threads $MAX_THREADS --max-difficulty $MAX_DIFFICULTY

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Nexus Network started successfully!${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "To view the session: ${YELLOW}screen -r nexus${NC}"
echo -e "To detach from screen: ${YELLOW}Press Ctrl+A then D${NC}"
echo -e "To stop Nexus: ${YELLOW}screen -X -S nexus quit${NC}"
echo -e "${GREEN}================================${NC}"
