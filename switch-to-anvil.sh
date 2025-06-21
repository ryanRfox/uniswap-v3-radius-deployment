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
echo "🚀 Ready to test deployment to Anvil with:"
echo "   # Start Anvil first:"
echo "   anvil"
echo "   # Then deploy:"
echo "   npm run deploy-anvil" 