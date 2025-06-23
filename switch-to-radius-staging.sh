#!/bin/bash

echo "🔄 Switching to Radius Staging Network configuration..."

# Copy Radius Staging environment file to active location
if [ ! -f ".env.radius-staging" ]; then
    echo "❌ Error: .env.radius-staging file not found!"
    echo "Please create .env.radius-staging with your staging network configuration."
    exit 1
fi

cp .env.radius-staging .env

# Use vanilla Uniswap code (NO nonce workarounds for staging)
if [ -d "uniswap-deploy-v3" ]; then
    echo "📁 Backing up current uniswap-deploy-v3..."
    rm -rf uniswap-deploy-v3.backup
    mv uniswap-deploy-v3 uniswap-deploy-v3.backup
fi

echo "📁 Cloning fresh vanilla Uniswap deployment tool..."
git clone https://github.com/Uniswap/deploy-v3.git uniswap-deploy-v3
cd uniswap-deploy-v3
npm install
cd ..

# Copy Radius Staging state file if it exists
if [ -f "networks/radius-staging/radius-staging-uniswap-v3-state.json" ]; then
    cp networks/radius-staging/radius-staging-uniswap-v3-state.json .
fi

echo "✅ Switched to Radius Staging Network"
echo "📋 Active configuration:"
echo "   • Environment: .env (from .env.radius-staging)"
echo "   • Deploy tool: uniswap-deploy-v3 (VANILLA - no workarounds)"
echo "   • State file: radius-staging-uniswap-v3-state.json"
echo ""
echo "============================================================"
echo "📋 NEXT STEPS:"
echo "============================================================"
echo ""
echo "1️⃣  Check your Radius staging balance:"
echo "    npm run check-balance"
echo ""
echo "2️⃣  If balance is low, get Radius staging ETH:"
echo "    📱 Visit: https://stg.tryradi.us/dashboard/faucet"
echo ""
echo "3️⃣  Test that nonce bug is fixed:"
echo "    npm run test-staging-nonce"
echo ""
echo "4️⃣  Deploy Uniswap V3 contracts (vanilla deployment):"
echo "    npm run deploy-staging"
echo ""
echo "✅ ADVANTAGE: No workarounds needed on staging network!"
echo "" 