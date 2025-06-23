#!/bin/bash

echo "🔄 Switching to Radius Network configuration..."

# Copy Radius environment file to active location
cp .env.radius-testnet .env

# Use the modified Uniswap code (with nonce fixes)
if [ -d "uniswap-deploy-v3" ]; then
    echo "📁 Backing up current uniswap-deploy-v3..."
    rm -rf uniswap-deploy-v3.backup
    mv uniswap-deploy-v3 uniswap-deploy-v3.backup
fi

echo "📁 Using existing Uniswap deployment tool..."
# No need to copy - we have a single working deployment tool

# Copy Radius state file if it exists
if [ -f "networks/radius/radius-uniswap-v3-state.json" ]; then
    cp networks/radius/radius-uniswap-v3-state.json .
fi

echo "✅ Switched to Radius Network"
echo "📋 Active configuration:"
echo "   • Environment: .env (from .env.radius-testnet)"
echo "   • Deploy tool: uniswap-deploy-v3 (modified with nonce fixes)"
echo "   • State file: radius-uniswap-v3-state.json"
echo ""
echo "============================================================"
echo "📋 NEXT STEPS:"
echo "============================================================"
echo ""
echo "1️⃣  Check your Radius testnet balance:"
echo "    npm run check-balance"
echo ""
echo "2️⃣  If balance is low, get Radius testnet ETH:"
echo "    📱 Visit: https://testnet.tryradi.us/dashboard/faucet"
echo ""
echo "3️⃣  Test network connectivity:"
echo "    npm run test-nonce"
echo ""
echo "4️⃣  Deploy Uniswap V3 contracts:"
echo "    npm run deploy"
echo ""
echo "⚠️  NOTE: Uses workarounds for Radius nonce validation issues"
echo "" 