# Radius Network Bug Report: Incorrect Nonce Validation on Read-Only Operations

**Date**: 20 June 2025
**Reporter**: Fox
**Severity**: High (Blocks Uniswap V3 deployment and other complex DApps)

## Summary

Radius testnet incorrectly validates transaction nonces on read-only JSON-RPC operations (`eth_call`, `eth_estimateGas`) when a `from` field is specified. This breaks compatibility with standard Ethereum tooling and prevents deployment of complex protocols like Uniswap V3.

## Deployment Context

**What we're deploying**: Uniswap V3 protocol suite (14 contracts) to Radius testnet

- **Repository**: https://github.com/Uniswap/deploy-v3 (Official Uniswap deployment tool)
- **Target Network**: Radius Testnet (Chain ID: 1223953)
- **Account**: `0x1F17E1Ac5393B926ACF1cB0837d3c9b6E2aB1a87` (Nonce: 1 after factory deployment)

## Bug Description

### Expected Behavior (Per Ethereum JSON-RPC Specification)

Read-only operations should **never** validate transaction nonces:

1. **`eth_call`**: Executes a message call immediately without creating a transaction

   - **Expected**: No nonce validation regardless of `from` field presence

2. **`eth_estimateGas`**: Estimates gas needed for a transaction without executing it
   - **Expected**: No nonce validation, only gas computation

### Actual Behavior on Radius

**Critical Discovery**: The bug is **nonce-dependent** - operations fail differently based on account nonce:

- **Nonce 0**: `eth_estimateGas` works correctly
- **Nonce 1+**: Both `eth_call` (with `from`) and `eth_estimateGas` fail with validation errors

```json
{
  "jsonrpc": "2.0",
  "id": 48,
  "error": {
    "code": -33009,
    "message": "Exec Failed",
    "data": "transaction validation error: nonce 0 too low, expected 1"
  }
}
```

**Impact**: This explains why Uniswap factory deployment succeeded (used nonce 0) but subsequent operations fail (require nonce 1+).

## Reproduction Test Suite

### Test Results Summary

| Network      | eth_call (no from) | eth_call (with from) | eth_estimateGas    |
| ------------ | ------------------ | -------------------- | ------------------ |
| **Anvil**    | ✅ Works           | ✅ Works             | ✅ Works           |
| **Radius**   | ✅ Works           | ❌ **Nonce Error**   | ❌ **Nonce Error** |
| **Expected** | ✅ Works           | ✅ Should Work       | ✅ Should Work     |

### Detailed Test Cases

#### Test 1: `eth_call` without `from` field

**Anvil (Expected Behavior)** ✅

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{
    "jsonrpc":"2.0",
    "method":"eth_call",
    "params":[{
      "to":"0x1D6188200d9bD32Db34725808FE76620dDceAcE2",
      "data":"0x8da5cb5b"
    },"latest"],
    "id":1
  }' \
  http://localhost:8545
```

**Result**: ✅ **SUCCESS** - Returns result without errors

**Radius Testnet** ✅

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{
    "jsonrpc":"2.0",
    "method":"eth_call",
    "params":[{
      "to":"0x1D6188200d9bD32Db34725808FE76620dDceAcE2",
      "data":"0x8da5cb5b"
    },"latest"],
    "id":1
  }' \
  https://rpc.testnet.tryradi.us/YOUR_API_KEY
```

**Result**: ✅ **SUCCESS** - Returns contract owner address

#### Test 2: `eth_call` with `from` field

**Anvil (Expected Behavior)** ✅

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{
    "jsonrpc":"2.0",
    "method":"eth_call",
    "params":[{
      "from":"0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
      "to":"0x1D6188200d9bD32Db34725808FE76620dDceAcE2",
      "data":"0x8da5cb5b"
    },"latest"],
    "id":1
  }' \
  http://localhost:8545
```

**Result**: ✅ **SUCCESS** - Works identical to Test 1 (standard behavior)

**Radius Testnet** ❌

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{
    "jsonrpc":"2.0",
    "method":"eth_call",
    "params":[{
      "from":"0x1F17E1Ac5393B926ACF1cB0837d3c9b6E2aB1a87",
      "to":"0x1D6188200d9bD32Db34725808FE76620dDceAcE2",
      "data":"0x8da5cb5b"
    },"latest"],
    "id":1
  }' \
  https://rpc.testnet.tryradi.us/YOUR_API_KEY
```

**Result**: ❌ **BUG** - Fails with nonce validation error:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -33009,
    "message": "Exec Failed",
    "data": "transaction validation error: nonce 0 too low, expected 1"
  }
}
```

#### Test 3: `eth_estimateGas`

**Anvil (Expected Behavior)** ✅

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{
    "jsonrpc":"2.0",
    "method":"eth_estimateGas",
    "params":[{
      "from":"0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
      "to":"0x1D6188200d9bD32Db34725808FE76620dDceAcE2",
      "data":"0x8da5cb5b"
    }],
    "id":1
  }' \
  http://localhost:8545
```

**Result**: ✅ **SUCCESS** - Returns gas estimate (e.g., `"0x5248"`)

**Radius Testnet** ❌

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{
    "jsonrpc":"2.0",
    "method":"eth_estimateGas",
    "params":[{
      "from":"0x1F17E1Ac5393B926ACF1cB0837d3c9b6E2aB1a87",
      "to":"0x1D6188200d9bD32Db34725808FE76620dDceAcE2",
      "data":"0x8a7c195f0000000000000000000000000000000000000000000000000000000000000064000000000000000000000000000000000000000000000000000000000000000a"
    }],
    "id":1
  }' \
  https://rpc.testnet.tryradi.us/YOUR_API_KEY
```

**Result**: ❌ **BUG** - Fails with nonce validation error:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -33009,
    "message": "Exec Failed",
    "data": "transaction validation error: nonce 0 too low, expected 1"
  }
}
```

## Impact on Uniswap V3 Deployment

### Deployment Sequence Analysis

The nonce-dependent bug creates a specific failure pattern:

1. **Step 1 (Nonce 0)**: ✅ Factory deployment succeeds
2. **Step 2 (Nonce 1)**: ❌ Add fee tier fails at gas estimation
3. **Steps 3-15**: ❌ All blocked by gas estimation failures

### Current Status

- ✅ **UniswapV3Factory**: Successfully deployed to `0x1D6188200d9bD32Db34725808FE76620dDceAcE2`
- ❌ **Remaining 13 contracts**: Blocked by nonce 1+ gas estimation bug

### Workaround (Partial)

`eth_call` with `from` field can be avoided:

```typescript
// ❌ FAILS: Contract object (adds 'from' field)
const owner = await contract.owner();

// ✅ WORKS: Direct provider call (no 'from' field)
const result = await provider.call({
  to: contractAddress,
  data: "0x8da5cb5b", // owner() selector
});
```

**Limitation**: No workaround exists for `eth_estimateGas` - deployment tools require gas estimation.

## Root Cause Analysis

Radius's RPC implementation has **nonce-dependent validation logic** that incorrectly applies to read-only operations:

- **Nonce 0**: Operations work correctly (standard behavior)
- **Nonce 1+**: Validation incorrectly applied to `eth_call` (with `from`) and `eth_estimateGas`

**Standard Ethereum behavior**: Nonce validation only applies to transaction submission (`eth_sendTransaction`, `eth_sendRawTransaction`), never to read-only operations regardless of account nonce.

## Reference Implementations

### Ethereum Mainnet/Testnets

- **Sepolia**: ✅ Correctly allows read operations with any nonce
- **Goerli**: ✅ Correctly allows read operations with any nonce
- **Mainnet**: ✅ Correctly allows read operations with any nonce

### Other L2s

- **Base**: ✅ Correctly implements read-only operations
- **Arbitrum**: ✅ Correctly implements read-only operations
- **Optimism**: ✅ Correctly implements read-only operations

## Canonical References

1. **Ethereum JSON-RPC Specification**

   - https://ethereum.org/en/developers/docs/apis/json-rpc/
   - Clearly states `eth_call` "does not create a transaction on the blockchain"

2. **Geth Implementation** (Reference client)

   - https://github.com/ethereum/go-ethereum/blob/master/internal/ethapi/api.go
   - Shows `eth_call` and `eth_estimateGas` do not validate nonces

3. **Ethereum Improvement Proposals**
   - EIP-1474: Remote procedure call specification
   - Defines standard behavior for JSON-RPC methods

## Recommended Fix

Update Radius's JSON-RPC handler to **skip nonce validation** for:

- `eth_call` operations (all cases)
- `eth_estimateGas` operations
- Any other read-only operations

## Reproduction Instructions

### Option 1: Node.js Test Script

```bash
# Install dependencies
npm install ethers

# Run the reproduction script
node test-nonce-bug.js
```

### Option 2: Manual curl Testing

**Test on Anvil (Expected Behavior):**

```bash
# Start Anvil
anvil

# Test eth_call with from field (should work)
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_call","params":[{"from":"0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266","to":"0x1D6188200d9bD32Db34725808FE76620dDceAcE2","data":"0x8da5cb5b"},"latest"],"id":1}' \
  http://localhost:8545

# Test eth_estimateGas (should work)
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_estimateGas","params":[{"from":"0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266","to":"0x1D6188200d9bD32Db34725808FE76620dDceAcE2","data":"0x8da5cb5b"}],"id":1}' \
  http://localhost:8545
```

**Test on Radius (Demonstrates Bug):**

```bash
# Test eth_call with from field (fails with nonce error)
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_call","params":[{"from":"0x1F17E1Ac5393B926ACF1cB0837d3c9b6E2aB1a87","to":"0x1D6188200d9bD32Db34725808FE76620dDceAcE2","data":"0x8da5cb5b"},"latest"],"id":1}' \
  https://rpc.testnet.tryradi.us/YOUR_API_KEY

# Test eth_estimateGas (fails with nonce error)
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_estimateGas","params":[{"from":"0x1F17E1Ac5393B926ACF1cB0837d3c9b6E2aB1a87","to":"0x1D6188200d9bD32Db34725808FE76620dDceAcE2","data":"0x8da5cb5b"}],"id":1}' \
  https://rpc.testnet.tryradi.us/YOUR_API_KEY
```

## Test Environment

- **Node.js**: 18.20.5
- **Ethers.js**: 5.8.0
- **Uniswap deploy-v3**: Latest (official repository)
- **Account Balance**: 1.0 ETH (sufficient for deployment)
- **Test Script**: `test-nonce-bug.js` (included in this repository)

## Contact

For questions about this bug report or to coordinate testing:

- **GitHub**: This repository contains full reproduction steps
- **Test Account**: `0x1F17E1Ac5393B926ACF1cB0837d3c9b6E2aB1a87` (available for Radius team testing)

---

**Priority**: This bug blocks deployment of major DeFi protocols and affects compatibility with standard Ethereum tooling. Resolution would enable Radius to support the full Ethereum ecosystem.
