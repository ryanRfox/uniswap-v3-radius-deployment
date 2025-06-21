#!/bin/bash

echo "🔄 Switching to Radius Network configuration..."

# Copy Radius environment file to active location
cp .env.radius .env

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
echo "   • Environment: .env (from .env.radius)"
echo "   • Deploy tool: uniswap-deploy-v3 (modified with nonce fixes)"
echo "   • State file: radius-uniswap-v3-state.json"
echo ""
echo "🚀 Ready to deploy to Radius with:"
echo "   npm run deploy" 