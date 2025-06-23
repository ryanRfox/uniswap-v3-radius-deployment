# Radius Staging Network Setup

This document covers the setup and testing process for deploying Uniswap V3 to the Radius Staging network.

## Overview

**Radius Staging** is a staging environment that is supposed to be **free from the nonce validation bug** that affects the main Radius testnet. This allows us to test vanilla Uniswap deployment without any workarounds.

## Key Differences from Main Radius

| Feature                | Radius Testnet   | Radius Staging  |
| ---------------------- | ---------------- | --------------- |
| **Nonce Bug**          | ❌ Present       | ✅ Fixed        |
| **Deployment Code**    | With workarounds | Vanilla Uniswap |
| **eth_call with from** | ❌ Fails         | ✅ Should work  |
| **eth_estimateGas**    | ❌ Fails         | ✅ Should work  |

## Setup Instructions

### 1. Configure Environment

Update `.env.radius-staging` template with your staging network credentials:

```bash
# Edit .env.radius-staging (template file)
export RADIUS_STAGING_API_KEY=your_staging_api_key_here
export RPC_URL=https://rpc.staging.tryradi.us/$RADIUS_STAGING_API_KEY
export CHAIN_ID=your_staging_chain_id
export PRIVATE_KEY=your_staging_private_key
export ADDRESS=your_staging_address
```

**Note**: This updates the template file. When you switch networks, it will be copied to `.env` (working file).

### 2. Switch to Staging Network

```bash
npm run switch-to-radius-staging
```

This command will:

- ✅ Copy `.env.radius-staging` template to `.env` (working file)
- ✅ Clone fresh vanilla Uniswap deployment tool (no workarounds)
- ✅ Set up state file for staging network

**Important**: The working environment is now in `.env`. Template files remain unchanged.

### 3. Verify Configuration

```bash
# Check balance
npm run check-balance

# Test deployment tool
npm run test-deploy-tool
```

## Testing Process

### Step 1: Test Network Connectivity

```bash
node docs/test-nonce-bug-staging.js
```

**Expected Results:**

- ✅ Test 1 (eth_call without from): Should pass
- ✅ Test 2 (eth_call with from): Should pass (no nonce error)
- ✅ Test 3 (eth_estimateGas): Should pass (no nonce error)

### Step 2: Deploy Uniswap V3

If nonce tests pass, proceed with deployment:

```bash
npm run deploy-staging
```

**Expected Behavior:**

- ✅ All 14 contracts should deploy successfully
- ✅ No nonce validation errors
- ✅ Standard gas estimation should work
- ✅ Contract calls should work normally

### Step 3: Verify Deployment

```bash
npm run update-env    # Updates working .env file (not template)
source .env           # Load updated working environment

# Test factory deployment
node -e "
const { ethers } = require('ethers');
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
const factoryAbi = ['function owner() view returns (address)'];
const factory = new ethers.Contract(process.env.FACTORY_ADDRESS, factoryAbi, provider);
factory.owner().then(owner => {
  console.log('✅ Factory Owner:', owner);
  console.log('🎉 Staging deployment verified!');
}).catch(err => console.error('❌ Test failed:', err.message));
"
```

## Troubleshooting

### Issue: "Insufficient balance"

**Solution:** Get Radius staging ETH from the [Radius Staging Faucet](https://stg.tryradi.us/dashboard/faucet).

### Issue: "Network connection failed"

```bash
# Check environment variables
source .env.radius-staging
echo "RPC URL: $RPC_URL"
echo "Chain ID: $CHAIN_ID"
```

**Solution:** Verify your staging API key and network configuration.

### Issue: "Nonce validation error"

If you still get nonce errors during testing:

```bash
node docs/test-nonce-bug-staging.js
```

**Solution:** The staging network may still have the bug. Contact Radius team for clarification.

### Issue: "Deploy tool not found"

```bash
# Re-run staging setup
npm run switch-to-radius-staging
```

**Solution:** The script will re-clone the vanilla deployment tool.

## File Structure

After running `npm run switch-to-radius-staging`:

```
├── .env                                    # Active environment (from .env.radius-staging)
├── .env.radius-staging                     # Staging network template
├── .env.radius-testnet                     # Main Radius testnet template
├── .env.base-sepolia                       # Base Sepolia template
├── .env.anvil                              # Anvil local template
├── uniswap-deploy-v3/                     # Fresh vanilla deployment tool
├── uniswap-deploy-v3.backup/              # Previous deployment tool (with workarounds)
├── radius-staging-uniswap-v3-state.json   # Deployment state
└── networks/radius-staging/               # Network-specific files
```

## Success Criteria

For a successful staging deployment:

1. ✅ **Nonce tests pass**: Both `eth_call` with `from` and `eth_estimateGas` work
2. ✅ **Factory deploys**: UniswapV3Factory contract deploys successfully
3. ✅ **Full deployment**: All 14 contracts deploy without errors
4. ✅ **Contract calls work**: Post-deployment verification succeeds

## Comparison with Main Radius

If staging deployment succeeds where main Radius fails, this confirms:

- ✅ **Bug isolation**: Nonce bug is specific to main testnet
- ✅ **Solution validity**: Vanilla Uniswap code works fine
- ✅ **Future path**: Main testnet can be fixed using staging approach

## Next Steps

After successful staging deployment:

1. **Document results**: Compare against main Radius deployment
2. **Report to Radius team**: Share staging success with main testnet issues
3. **Plan migration**: Prepare for when main testnet is fixed
4. **Use staging**: For testing and development until main testnet is fixed

---

**Created**: December 2024  
**Status**: Ready for testing  
**Contact**: Use for questions about staging network deployment
