#!/usr/bin/env node

/**
 * Radius Network Nonce Validation Bug Reproduction Script
 * 
 * This script demonstrates the incorrect nonce validation on read-only operations.
 * Run with: node test-nonce-bug.js
 */

const { ethers } = require('ethers');

// Configuration
const RADIUS_RPC = 'https://rpc.testnet.tryradi.us/YOUR_API_KEY_HERE';
const TEST_CONTRACT = '0x1D6188200d9bD32Db34725808FE76620dDceAcE2'; // UniswapV3Factory
const TEST_ACCOUNT = '0x1F17E1Ac5393B926ACF1cB0837d3c9b6E2aB1a87';
const OWNER_SELECTOR = '0x8da5cb5b'; // owner() function selector

async function testRadiusNonceBug() {
  console.log('🧪 Radius Network Nonce Validation Bug Test');
  console.log('============================================\n');

  const provider = new ethers.providers.JsonRpcProvider(RADIUS_RPC);
  
  try {
    // Get current network and account state
    const network = await provider.getNetwork();
    const blockNumber = await provider.getBlockNumber();
    
    console.log(`🌐 Network: ${network.name} (Chain ID: ${network.chainId})`);
    console.log(`📦 Block Number: ${blockNumber}`);
    console.log(`🏭 Test Contract: ${TEST_CONTRACT}`);
    console.log(`👤 Test Account: ${TEST_ACCOUNT}\n`);

    // Test 1: eth_call without 'from' field (should work)
    console.log('📞 Test 1: eth_call WITHOUT from field');
    console.log('Expected: ✅ SUCCESS (standard Ethereum behavior)');
    try {
      const result1 = await provider.call({
        to: TEST_CONTRACT,
        data: OWNER_SELECTOR
      });
      console.log('✅ PASS: Call succeeded');
      console.log(`   Result: ${result1}\n`);
    } catch (err) {
      console.log('❌ FAIL: Unexpected error');
      console.log(`   Error: ${err.message}\n`);
    }

    // Test 2: eth_call with 'from' field (fails on Radius, works on standard Ethereum)
    console.log('📞 Test 2: eth_call WITH from field');
    console.log('Expected: ✅ SUCCESS (should work like Test 1)');
    console.log('Radius Actual: ❌ NONCE ERROR (THIS IS THE BUG)');
    try {
      const result2 = await provider.call({
        to: TEST_CONTRACT,
        data: OWNER_SELECTOR,
        from: TEST_ACCOUNT
      });
      console.log('✅ PASS: Call succeeded (bug is fixed!)');
      console.log(`   Result: ${result2}\n`);
    } catch (err) {
      if (err.message.includes('nonce')) {
        console.log('❌ BUG CONFIRMED: Nonce validation error on read-only operation');
        console.log(`   Error: ${err.error?.data || 'nonce validation error'}\n`);
      } else {
        console.log('❌ DIFFERENT ERROR: Not the expected nonce bug');
        console.log(`   Error: ${err.message}\n`);
      }
    }

    // Test 3: eth_estimateGas (fails on Radius, works on standard Ethereum)
    console.log('⛽ Test 3: eth_estimateGas');
    console.log('Expected: ✅ SUCCESS (should return gas estimate)');
    console.log('Radius Actual: ❌ NONCE ERROR (THIS IS THE BUG)');
    try {
      const gasEstimate = await provider.estimateGas({
        to: TEST_CONTRACT,
        data: '0x8a7c195f0000000000000000000000000000000000000000000000000000000000000064000000000000000000000000000000000000000000000000000000000000000a',
        from: TEST_ACCOUNT
      });
      console.log('✅ PASS: Gas estimation succeeded (bug is fixed!)');
      console.log(`   Gas Estimate: ${gasEstimate.toString()}\n`);
    } catch (err) {
      if (err.message.includes('nonce')) {
        console.log('❌ BUG CONFIRMED: Nonce validation error on gas estimation');
        console.log(`   Error: ${err.error?.data || 'nonce validation error'}\n`);
      } else {
        console.log('❌ DIFFERENT ERROR: Not the expected nonce bug');
        console.log(`   Error: ${err.message}\n`);
      }
    }

    // Summary
    console.log('📋 SUMMARY');
    console.log('==========');
    console.log('This demonstrates that Radius incorrectly validates nonces on:');
    console.log('• eth_call operations when "from" field is present');
    console.log('• eth_estimateGas operations');
    console.log('');
    console.log('These are READ-ONLY operations that should never validate nonces.');
    console.log('Standard Ethereum networks (mainnet, testnets, other L2s) allow these operations.');
    console.log('');
    console.log('Impact: Breaks compatibility with standard Ethereum tooling and DApp deployments.');

  } catch (err) {
    console.log(`❌ Network connection failed: ${err.message}`);
    console.log('Make sure to replace YOUR_API_KEY_HERE with a valid Radius API key.');
  }
}

// Run the test
if (require.main === module) {
  testRadiusNonceBug().catch(console.error);
}

module.exports = { testRadiusNonceBug }; 