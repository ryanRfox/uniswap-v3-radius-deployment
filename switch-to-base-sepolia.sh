#!/bin/bash

echo "🔄 Switching to Base Sepolia Network configuration..."

# Copy Base Sepolia environment file to active location
cp .env.base-sepolia .env

# Use the original Uniswap code (unmodified)
if [ -d "uniswap-deploy-v3" ]; then
    echo "📁 Backing up current uniswap-deploy-v3..."
    rm -rf uniswap-deploy-v3.backup
    mv uniswap-deploy-v3 uniswap-deploy-v3.backup
fi

echo "📁 Using existing Uniswap deployment tool..."
# No need to copy - we have a single working deployment tool

# Create fresh state file for Base Sepolia
echo "📄 Creating fresh state file for Base Sepolia..."
echo "{}" > base-sepolia-uniswap-v3-state.json

echo "✅ Switched to Base Sepolia Network"
echo "📋 Active configuration:"
echo "   • Environment: .env (from .env.base-sepolia)"
echo "   • Deploy tool: uniswap-deploy-v3 (original, unmodified)"
echo "   • State file: base-sepolia-uniswap-v3-state.json"
echo ""
echo "============================================================"
echo "📋 NEXT STEPS:"
echo "============================================================"
echo ""
echo "1️⃣  Verify your wallet has Base Sepolia ETH:"
echo "    npm run check-balance"
echo ""
echo "2️⃣  If balance is low, get testnet ETH:"
echo "    📱 Visit: https://faucet.quicknode.com/base/sepolia"
echo ""
echo "3️⃣  Deploy Uniswap V3 contracts:"
echo "    npm run deploy"
echo ""
echo "💡 TIP: You'll need ~0.5 ETH for full deployment"
echo "" 