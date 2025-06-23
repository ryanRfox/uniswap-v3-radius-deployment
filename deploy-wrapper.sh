#!/bin/bash

# Deployment Wrapper Script - Adds next-step instructions after deployment

NETWORK="$1"
DEPLOY_COMMAND="$2"

if [ -z "$NETWORK" ] || [ -z "$DEPLOY_COMMAND" ]; then
    echo "Usage: ./deploy-wrapper.sh <network-name> <deploy-command>"
    exit 1
fi

echo "🚀 Starting $NETWORK deployment..."
echo ""

# Run the deployment command
eval "$DEPLOY_COMMAND"
DEPLOY_EXIT_CODE=$?

echo ""
echo "============================================================"

if [ $DEPLOY_EXIT_CODE -eq 0 ]; then
    echo "🎉 $NETWORK DEPLOYMENT COMPLETED SUCCESSFULLY!"
    echo "============================================================"
    echo ""
    echo "📋 NEXT STEPS:"
    echo "============================================================"
    echo ""
    echo "1️⃣  Update environment with deployed contract addresses:"
    echo "    npm run update-env"
    echo ""
    echo "2️⃣  Load the updated environment:"
    echo "    source .env"
    echo ""
    echo "3️⃣  Verify deployment is working:"
    echo "    npm run verify-deployment"
    echo ""
    echo "4️⃣  Test factory functionality:"
    echo "    node -e \""
    echo "      const { ethers } = require('ethers');"
    echo "      const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);"
    echo "      const factoryAbi = ['function owner() view returns (address)'];"
    echo "      const factory = new ethers.Contract(process.env.FACTORY_ADDRESS, factoryAbi, provider);"
    echo "      factory.owner().then(owner => console.log('Factory Owner:', owner));"
    echo "    \""
    echo ""
    echo "🎉 Your Uniswap V3 deployment on $NETWORK is ready to use!"
    echo ""
else
    echo "❌ $NETWORK DEPLOYMENT FAILED!"
    echo "============================================================"
    echo ""
    echo "📋 TROUBLESHOOTING STEPS:"
    echo "============================================================"
    echo ""
    echo "1️⃣  Check your balance:"
    echo "    npm run check-balance"
    echo ""
    echo "2️⃣  Verify network configuration:"
    echo "    source .env && echo \"Network: \$NETWORK_NAME\""
    echo ""
    echo "3️⃣  Check deployment tool:"
    echo "    npm run test-deploy-tool"
    echo ""
    if [ "$NETWORK" = "Radius" ]; then
        echo "4️⃣  Test for nonce issues (Radius specific):"
        echo "    npm run test-nonce"
        echo ""
        echo "5️⃣  Try Radius Staging (if available):"
        echo "    npm run switch-to-radius-staging"
        echo ""
    fi
    echo "💡 Check the error messages above for specific issues"
    echo ""
fi 