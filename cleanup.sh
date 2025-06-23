#!/bin/bash

set -e  # Exit on any error

echo "🧹 Uniswap V3 Deployment Cleanup Script"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the right directory
if [[ ! -f "package.json" ]] || [[ ! -f "README.md" ]]; then
    print_error "This doesn't appear to be the uniswap-v3-radius-deployment directory"
    print_error "Please run this script from the project root"
    exit 1
fi

print_info "Current directory: $(pwd)"
print_info "Git branch: $(git branch --show-current 2>/dev/null || echo 'not a git repo')"
echo ""

# Show what will be cleaned up
echo "🔍 Scanning for files to clean up..."
echo ""

# Check for deployment state files
STATE_FILES=($(find . -maxdepth 1 -name "*uniswap*.json" -o -name "*state*.json" | grep -v node_modules || true))
if [[ ${#STATE_FILES[@]} -gt 0 ]]; then
    print_info "Found deployment state files:"
    for file in "${STATE_FILES[@]}"; do
        echo "   📄 $file"
    done
else
    print_info "No deployment state files found"
fi
echo ""

# Check for cleanable directories/files
CLEANABLE_DIRS=()
CLEANABLE_FILES=()

[[ -d "node_modules" ]] && CLEANABLE_DIRS+=("node_modules/")
[[ -d "uniswap-deploy-v3" ]] && CLEANABLE_DIRS+=("uniswap-deploy-v3/")
[[ -d "uniswap-deploy-v3.backup" ]] && CLEANABLE_DIRS+=("uniswap-deploy-v3.backup/")
# Find any other backup directories
for dir in *.backup/; do
    [[ -d "$dir" ]] && CLEANABLE_DIRS+=("$dir")
done

[[ -f "package-lock.json" ]] && CLEANABLE_FILES+=("package-lock.json")

if [[ ${#CLEANABLE_DIRS[@]} -gt 0 ]]; then
    print_info "Directories to remove:"
    for dir in "${CLEANABLE_DIRS[@]}"; do
        echo "   📁 $dir"
    done
fi

if [[ ${#CLEANABLE_FILES[@]} -gt 0 ]]; then
    print_info "Files to remove:"
    for file in "${CLEANABLE_FILES[@]}"; do
        echo "   📄 $file"
    done
fi

if [[ ${#CLEANABLE_DIRS[@]} -eq 0 ]] && [[ ${#CLEANABLE_FILES[@]} -eq 0 ]] && [[ ${#STATE_FILES[@]} -eq 0 ]]; then
    print_status "Repository is already clean!"
    exit 0
fi

echo ""
print_warning "This will:"
echo "  • Create /deployments folder (already in .gitignore)"
echo "  • Move deployment state files to timestamped subfolders"
echo "  • Copy the .env.<network> file used for deployment"
echo "  • Remove temporary/downloadable files and directories"
echo "  • Preserve original .env* files and source code"
echo ""

# Confirmation prompt
read -p "Do you want to proceed? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Cleanup cancelled"
    exit 0
fi

echo ""
print_info "Starting cleanup..."

# Step 1: Create deployments folder
print_info "Creating deployments folder structure..."
mkdir -p deployments
print_status "Created deployments/ folder"

# Step 2: Move deployment state files and environment to timestamped subfolder
if [[ ${#STATE_FILES[@]} -gt 0 ]]; then
    # Create timestamp folder
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    NETWORK=$(git branch --show-current 2>/dev/null || echo "unknown")
    DEPLOYMENT_DIR="deployments/${TIMESTAMP}_${NETWORK}"
    
    mkdir -p "$DEPLOYMENT_DIR"
    print_info "Created deployment subfolder: $DEPLOYMENT_DIR"
    
    # Move state files
    for file in "${STATE_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            mv "$file" "$DEPLOYMENT_DIR/"
            print_status "Moved $(basename "$file") to $DEPLOYMENT_DIR/"
        fi
    done
    
    # Copy the current .env.<network> file used for this deployment
    if [[ -f ".env" ]]; then
        # Try to determine which .env.<network> file was used by checking content
        ENV_CONTENT=$(cat .env)
        NETWORK_ENV_FILE=""
        
        if [[ "$ENV_CONTENT" == *"Anvil Local"* ]]; then
            NETWORK_ENV_FILE=".env.anvil"
        elif [[ "$ENV_CONTENT" == *"Base Sepolia"* ]]; then
            NETWORK_ENV_FILE=".env.base-sepolia"
        elif [[ "$ENV_CONTENT" == *"Radius Testnet"* ]]; then
            NETWORK_ENV_FILE=".env.radius-testnet"
        elif [[ "$ENV_CONTENT" == *"Radius Staging"* ]]; then
            NETWORK_ENV_FILE=".env.radius-staging"
        fi
        
        if [[ -n "$NETWORK_ENV_FILE" ]] && [[ -f "$NETWORK_ENV_FILE" ]]; then
            cp "$NETWORK_ENV_FILE" "$DEPLOYMENT_DIR/"
            print_status "Copied $NETWORK_ENV_FILE to $DEPLOYMENT_DIR/"
        else
            print_warning "Could not determine source .env.<network> file"
        fi
    fi
    
    # Create a deployment info file
    cat > "$DEPLOYMENT_DIR/deployment-info.txt" << EOF
Deployment Information
=====================
Date: $(date)
Branch: $NETWORK
Working Directory: $(pwd)
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo "not available")
Git Status: $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ') files modified

Files in this deployment:
$(ls -la "$DEPLOYMENT_DIR/" | grep -v "deployment-info.txt" || echo "No deployment files")

Network environment file: $(basename "$NETWORK_ENV_FILE" 2>/dev/null || echo "Not detected")
EOF
    print_status "Created deployment info file"
fi

# Step 3: Clean up temporary directories
for dir in "${CLEANABLE_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        rm -rf "$dir"
        print_status "Removed $dir"
    fi
done

# Step 4: Clean up temporary files
for file in "${CLEANABLE_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        rm -f "$file"
        print_status "Removed $file"
    fi
done

echo ""
print_status "Cleanup completed successfully!"
echo ""
print_info "Summary:"
print_info "• Repository is now in a fresh state"
print_info "• Deployment state and environment preserved in deployments/ folder"
print_info "• Original .env* files preserved in project root"
print_info "• Temporary/downloadable files removed"
echo ""
print_info "To restore working state:"
echo "  npm install      # Restore node_modules"
echo "  npm run setup    # Re-download uniswap-deploy-v3"
echo ""
print_info "To see deployment history:"
echo "  ls -la deployments/"
echo "" 