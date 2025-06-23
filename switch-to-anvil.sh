#!/bin/bash

echo "🔄 Switching to Anvil Local Network configuration..."

# Copy Anvil environment file to active location
cp .env.anvil .env

# Use the original Uniswap code (unmodified)
if [ -d "uniswap-deploy-v3" ]; then
    echo "📁 Backing up current uniswap-deploy-v3..."
    rm -rf uniswap-deploy-v3.backup
    mv uniswap-deploy-v3 uniswap-deploy-v3.backup
fi

echo "📁 Using existing Uniswap deployment tool..."
# No need to copy - we have a single working deployment tool

# Create fresh state file for Anvil
echo "📄 Creating fresh state file for Anvil..."
echo "{}" > anvil-uniswap-v3-state.json

echo "✅ Switched to Anvil Local Network"
echo "📋 Active configuration:"
echo "   • Environment: .env (from .env.anvil)"
echo "   • Deploy tool: uniswap-deploy-v3 (original, unmodified)"
echo "   • State file: anvil-uniswap-v3-state.json"
echo ""
echo "============================================================"
echo "📋 NEXT STEPS:"
echo "============================================================"
echo ""
echo "1️⃣  Start Anvil local blockchain:"
echo "    anvil"
echo ""
echo "2️⃣  Check your balance (in new terminal):"
echo "    npm run check-balance"
echo ""
echo "3️⃣  Deploy Uniswap V3 contracts:"
echo "    npm run deploy"
echo ""
echo "💡 TIP: Anvil provides unlimited test ETH for fast development!"
echo "" 