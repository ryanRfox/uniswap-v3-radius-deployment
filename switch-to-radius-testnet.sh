#!/bin/bash

echo "🔄 Switching to Radius Testnet configuration..."

# Copy Radius Testnet environment file to active location
cp .env.radius-testnet .env

echo "📁 Using Uniswap deployment tool..."

# Copy Radius Testnet state file if it exists
if [ -f "networks/radius-testnet/radius-testnet-uniswap-v3-state.json" ]; then
    cp networks/radius-testnet/radius-testnet-uniswap-v3-state.json radius-testnet-uniswap-v3-state.json
fi

echo "✅ Switched to Radius Testnet"
echo "📋 Active configuration:"
echo "   • Environment: .env (from .env.radius-testnet)"
echo "   • Deploy tool: uniswap-deploy-v3 (modified with nonce fixes)"
echo "   • State file: radius-testnet-uniswap-v3-state.json"
echo ""
echo "🚀 Ready to deploy to Radius Testnet with:"
echo "   npm run deploy" 