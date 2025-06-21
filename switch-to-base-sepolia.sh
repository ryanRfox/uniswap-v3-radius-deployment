#!/bin/bash

echo "🔄 Switching to Base Sepolia Network configuration..."

# Copy Base Sepolia environment file to active location
cp .env.base.sepolia .env

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
echo "   • Environment: .env (from .env.base.sepolia)"
echo "   • Deploy tool: uniswap-deploy-v3 (original, unmodified)"
echo "   • State file: base-sepolia-uniswap-v3-state.json"
echo ""
echo "🚀 Ready to test deployment to Base Sepolia with:"
echo "   npm run deploy-base-sepolia" 