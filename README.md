# Uniswap V3 Multi-Network Deployment

Deploy Uniswap V3 to **Radius**, **Base Sepolia**, or **Anvil** networks using the official Uniswap deployment tool.

## Quick Start

```bash
# 1. Setup
npm install
npm run setup

# 2. Choose Network
npm run switch-to-anvil      # Local development
npm run switch-to-radius     # Radius testnet
npm run switch-to-base-sepolia # Base Sepolia testnet

# 3. Deploy
npm run check-balance
npm run deploy

# 4. Update environment with deployed addresses
npm run update-env
```

## Networks

| Network          | Purpose           | Status     | Requirements           |
| ---------------- | ----------------- | ---------- | ---------------------- |
| **Anvil**        | Local development | ✅ Working | Anvil running locally  |
| **Base Sepolia** | L2 testnet        | ✅ Working | Sepolia ETH via faucet |
| **Radius**       | Radius testnet    | ⚠️ Partial | Radius testnet ETH     |

### Network Details

**🔧 Anvil** - Fast local development

- Instant transactions, unlimited ETH
- Perfect for testing and development
- Start with: `npm run start-anvil`

**🌐 Base Sepolia** - Ethereum L2 testnet

- Standard Ethereum behavior
- Good for testing real network conditions
- Get ETH: [Base Sepolia Faucet](https://faucet.quicknode.com/base/sepolia)

**🚀 Radius** - Radius testnet

- Experimental network with some RPC quirks
- Factory deployment works, full deployment has nonce issues
- Get ETH: [Radius Faucet](https://faucet.testnet.tryradi.us)

## System Requirements

- **Node.js**: 18.x or 20.x
- **npm**: 9.0.0+
- **Git**: Any recent version
- **ETH Balance**: 0.5+ ETH for deployment (varies by network)

## Setup

### 1. Install Dependencies

```bash
npm install
npm run setup
```

### 2. Choose Your Network

```bash
# For local development (recommended)
npm run start-anvil          # Start Anvil in background
npm run switch-to-anvil      # Switch to Anvil config

# For testnet deployment
npm run switch-to-base-sepolia
# or
npm run switch-to-radius
```

### 3. Verify Setup

```bash
npm run check-balance        # Check account balance
npm run test-deploy-tool     # Test deployment tool
```

## Deployment

### Deploy All Contracts

```bash
npm run deploy
```

This will deploy all 14 Uniswap V3 contracts:

- UniswapV3Factory
- SwapRouter02
- NonfungiblePositionManager
- QuoterV2
- And 10 other supporting contracts

### Update Environment

```bash
npm run update-env           # Add contract addresses to .env file
source .env                  # Load updated environment
```

## Verification

Test your deployment:

```bash
source .env
node -e "
const { ethers } = require('ethers');
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
const factoryAbi = ['function owner() view returns (address)'];
const factory = new ethers.Contract(process.env.FACTORY_ADDRESS, factoryAbi, provider);
factory.owner().then(owner => {
  console.log('✅ Factory Owner:', owner);
  console.log('🎉 Deployment verified!');
}).catch(err => console.error('❌ Test failed:', err.message));
"
```

## Available Scripts

| Script                           | Description                |
| -------------------------------- | -------------------------- |
| `npm run setup`                  | Install deployment tool    |
| `npm run start-anvil`            | Start Anvil local node     |
| `npm run switch-to-anvil`        | Switch to Anvil network    |
| `npm run switch-to-base-sepolia` | Switch to Base Sepolia     |
| `npm run switch-to-radius`       | Switch to Radius network   |
| `npm run check-balance`          | Check account balance      |
| `npm run deploy`                 | Deploy all contracts       |
| `npm run update-env`             | Update .env with addresses |
| `npm run test-deploy-tool`       | Test deployment tool       |

## Known Issues

### TypeScript Compatibility - RESOLVED ✅

- **Fixed**: Using `tsx` instead of `ts-node` for better compatibility
- **Performance**: Significantly faster execution

### Radius Network Limitations

- **Factory Deployment**: ✅ Works perfectly
- **Full Deployment**: ⚠️ Blocked by RPC nonce validation bug
- **Workaround**: Factory is sufficient for basic pool creation

## Troubleshooting

### Common Issues

**"Insufficient funds"**

- Get testnet ETH from network faucet
- Need 0.5+ ETH for full deployment

**"Network connection failed"**

- Check if Anvil is running (for local)
- Verify API keys in environment files

**"TypeScript errors"**

- Run `npm run setup` to reinstall dependencies
- Ensure Node.js 18.x or 20.x

### Debug Commands

```bash
# Check versions
node --version
npm --version

# Check current network
source .env && echo "Network: $NETWORK_NAME"

# View deployment progress
cat *-uniswap-v3-state.json
```

## File Structure

```
├── README.md                    # This file - main documentation
├── package.json                 # Project dependencies and scripts
├── setup.js                     # Deployment tool installer
├── update-env.js                # Environment updater
├── switch-to-*.sh               # Network switching scripts
├── .env.*                       # Network configurations
├── *-uniswap-v3-state.json      # Deployment state files
└── uniswap-deploy-v3/           # Official Uniswap deployment tool
```

## Next Steps

After successful deployment:

1. **Create Pools**: Use factory to create token pairs
2. **Add Liquidity**: Use Position Manager for liquidity provision
3. **Build Interface**: Create frontend for your deployment
4. **Deploy Tokens**: Create ERC20 tokens to trade

## Resources

- [Uniswap V3 Documentation](https://docs.uniswap.org/contracts/v3/overview)
- [Official Deploy Tool](https://github.com/Uniswap/deploy-v3)
- [Anvil Documentation](https://book.getfoundry.sh/anvil/)
- [Base Documentation](https://docs.base.org/)
- [Radius Documentation](https://docs.tryradi.us/)
