# Uniswap V3 Multi-Network Deployment

Deploy Uniswap V3 to **Radius**, **Base Sepolia**, or **Anvil** networks using the official Uniswap deployment tool.

## Quick Start

```bash
# 1. Setup
npm install
npm run setup

# 2. Configure Network (example: Radius Testnet)
cp .env.radius-testnet.example .env.radius-testnet
# Edit .env.radius-testnet with your credentials

# 3. Deploy
npm run switch-to-radius-testnet
npm run check-balance
npm run deploy
npm run update-env
```

## Network Configuration

| Network            | Command                            | Setup Instructions                                   |
| ------------------ | ---------------------------------- | ---------------------------------------------------- |
| **Anvil**          | `npm run switch-to-anvil`          | Ready to use (no setup needed)                       |
| **Radius Testnet** | `npm run switch-to-radius-testnet` | `cp .env.radius-testnet.example .env.radius-testnet` |
| **Base Sepolia**   | `npm run switch-to-base-sepolia`   | `cp .env.base-sepolia.example .env.base-sepolia`     |

### Network Details

**🔧 Anvil** - Fast local development

- Instant transactions, unlimited test ETH
- Perfect for testing and development

**🌐 Base Sepolia** - Ethereum L2 testnet

- Standard Ethereum behavior
- Get ETH: [Base Sepolia Faucet](https://faucet.quicknode.com/base/sepolia)

**🚀 Radius Testnet** - Radius network deployment

- Get API key: [Radius Dashboard](https://testnet.tryradi.us/dashboard)
- Get ETH: [Radius Faucet](https://testnet.tryradi.us/dashboard/faucet)

## System Requirements

- **Node.js**: 18.x or 20.x
- **npm**: 9.0.0+
- **Git**: Any recent version
- **ETH Balance**: 0.5+ ETH for deployment (varies by network)

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
npm run setup
```

### 2. Configure Your Network

The switch scripts copy your network-specific configuration to `.env` which is used by the deployment tool.

**For Anvil (Local Development):**

```bash
npm run switch-to-anvil  # Ready to use immediately
```

**For Radius Testnet:**

```bash
# Copy and configure network-specific file
cp .env.radius-testnet.example .env.radius-testnet

# Edit .env.radius-testnet with:
# - Your API key from https://testnet.tryradi.us/dashboard
# - Your private key and wallet address
# - Get testnet ETH from the faucet

# Switch to use this configuration (copies .env.radius-testnet → .env)
npm run switch-to-radius-testnet
```

**For Base Sepolia:**

```bash
# Copy and configure network-specific file
cp .env.base-sepolia.example .env.base-sepolia

# Edit .env.base-sepolia with:
# - Your private key and wallet address
# - Get testnet ETH from https://faucet.quicknode.com/base/sepolia

# Switch to use this configuration (copies .env.base-sepolia → .env)
npm run switch-to-base-sepolia
```

### 3. Deploy

```bash
npm run check-balance     # Verify you have enough ETH
npm run deploy           # Deploy all 14 Uniswap V3 contracts
npm run update-env       # Update .env with deployed addresses
```

### 4. Archive Deployment (Optional)

```bash
npm run cleanup          # Archive deployment to /deployments folder
```

This moves deployment files to timestamped folders in `/deployments` and cleans temporary files for a fresh repository state.

## Available Scripts

| Script                             | Description                                |
| ---------------------------------- | ------------------------------------------ |
| `npm run setup`                    | Install Uniswap deployment tool            |
| `npm run switch-to-anvil`          | Switch to Anvil local network              |
| `npm run switch-to-radius-testnet` | Switch to Radius testnet                   |
| `npm run switch-to-base-sepolia`   | Switch to Base Sepolia                     |
| `npm run check-balance`            | Check wallet balance                       |
| `npm run deploy`                   | Deploy all contracts                       |
| `npm run update-env`               | Update environment with deployed addresses |
| `npm run cleanup`                  | Archive deployment and clean repository    |
| `npm run verify-deployment`        | Test deployed contracts                    |

## Deployed Contracts

After successful deployment, you'll have all 14 Uniswap V3 contracts:

- **UniswapV3Factory** - Core factory contract
- **SwapRouter02** - Universal router for swaps
- **NonfungiblePositionManager** - NFT position management
- **QuoterV2** - Price quotation
- **And 10 additional supporting contracts**

## Deployment Management

### Archive Deployments

After deploying, you can archive your deployment for future reference:

```bash
npm run cleanup
```

This creates a timestamped folder in `/deployments` containing:

- **Deployment state files** - Contract addresses and deployment info
- **Environment configuration** - The `.env.<network>` file used for deployment
- **Deployment summary** - Complete deployment context and metadata

The script also removes temporary files (`node_modules/`, `package-lock.json`, etc.) to return the repository to a clean state for the next deployment.

### View Deployment History

```bash
ls deployments/           # See all archived deployments
cat deployments/*/deployment-info.txt    # View deployment summaries
```

## Troubleshooting

**"Insufficient funds"**

- Get testnet ETH from the appropriate faucet
- Need ~0.5 ETH for full deployment

**"Network connection failed"**

- Check your API keys and RPC URLs
- Verify network configuration in your `.env.*` file

**"Module not found"**

- Run `npm run setup` to reinstall dependencies
- Ensure Node.js 18.x or 20.x

## Contributing

This project uses standard environment file conventions:

- `.env.*.example` files are public templates
- Copy to `.env.*` and fill in your credentials
- Never commit real credentials to the repository

## License

MIT License - see LICENSE file for details
