#!/bin/bash

echo "🔄 Switching to Radius Staging configuration..."

# Copy Radius Staging environment file to active location
cp .env.radius-staging .env

echo "📁 Using Uniswap deployment tool..."

# Copy Radius Staging state file if it exists
if [ -f "networks/radius-staging/radius-staging-uniswap-v3-state.json" ]; then
    cp networks/radius-staging/radius-staging-uniswap-v3-state.json radius-staging-uniswap-v3-state.json
fi

echo "✅ Switched to Radius Staging"
echo "📋 Active configuration:"
echo "   • Environment: .env (from .env.radius-staging)"
echo "   • Deploy tool: uniswap-deploy-v3 (modified with nonce fixes)"
echo "   • State file: radius-staging-uniswap-v3-state.json"
echo ""
echo "🚀 Ready to deploy to Radius Staging with:"
echo "   npm run deploy"
