#!/bin/bash

# Weaver Networks — HomeStation Bootstrap
# This script is the public front door to the HomeStation install process.
# It installs GitHub CLI, authenticates, then hands off to the private install.sh
#
# Usage: curl -fsSL https://raw.githubusercontent.com/Weaver-Networks/bootstrap/main/bootstrap.sh | bash

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BOLD}Weaver Networks — HomeStation Bootstrap${NC}"
echo "========================================="
echo ""
echo "This script will:"
echo "  1. Install GitHub CLI (gh)"
echo "  2. Authenticate with GitHub"
echo "  3. Clone the HomeStation repository"
echo "  4. Run the full install process"
echo ""
echo -e "${YELLOW}You will need:${NC}"
echo "  • A GitHub account that has been added as a collaborator"
echo "  • Signal contact with Sam for the mesh handshake step"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# ── Step 1: Install gh ──────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}Step 1: Installing GitHub CLI...${NC}"

if command -v gh &>/dev/null; then
    echo -e "${GREEN}✓ gh already installed — $(gh --version | head -1)${NC}"
else
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
        sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
        sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update && sudo apt install -y gh
    echo -e "${GREEN}✓ gh installed${NC}"
fi

# ── Step 2: Authenticate ────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}Step 2: GitHub authentication...${NC}"

if gh auth status &>/dev/null; then
    echo -e "${GREEN}✓ Already authenticated with GitHub${NC}"
else
    echo "Visit https://github.com/login/device and enter the code shown below."
    echo "You can do this from any browser on any device."
    echo ""
    gh auth login --hostname github.com --git-protocol https
    echo -e "${GREEN}✓ GitHub authentication complete${NC}"
fi

# ── Step 3: Clone homestation ───────────────────────────────────────────────

echo ""
echo -e "${BOLD}Step 3: Cloning HomeStation repository...${NC}"

if [ -d "$HOME/homestation" ]; then
    echo -e "${YELLOW}⚠ ~/homestation already exists — pulling latest...${NC}"
    cd ~/homestation
    git pull origin main
else
    gh repo clone Weaver-Networks/homestation ~/homestation
    echo -e "${GREEN}✓ Repository cloned${NC}"
fi

# ── Step 4: Hand off to install.sh ─────────────────────────────────────────

echo ""
echo -e "${BOLD}Step 4: Starting HomeStation install...${NC}"
echo ""

chmod +x ~/homestation/install.sh
bash ~/homestation/install.sh

