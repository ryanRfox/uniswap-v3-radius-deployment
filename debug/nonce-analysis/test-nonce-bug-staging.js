#!/usr/bin/env node

/**
 * Radius Staging Network Nonce Validation Test
 * 
 * This script tests that Radius Staging network does NOT have the nonce bug.
 * Run with: node docs/test-nonce-bug-staging.js
 */

const { ethers } = require('ethers');

// Configuration - read from environment variables
const RADIUS_STAGING_RPC = process.env.RPC_URL;
const TEST_CONTRACT = process.env.FACTORY_ADDRESS || '0x0000000000000000000000000000000000000000'; // Use factory if deployed
const TEST_ACCOUNT = process.env.DEPLOYER_ADDRESS;
const OWNER_SELECTOR = '0x8da5cb5b'; // owner() function selector

// Validate environment
if (!RADIUS_STAGING_RPC) {
  console.error('❌ Error: RPC_URL not found in environment');
  console.error('Make sure to run: npm run switch-to-radius-staging');
  process.exit(1);
}

if (!TEST_ACCOUNT) {
  console.error('❌ Error: DEPLOYER_ADDRESS not found in environment');
  console.error('Make sure your .env.radius-staging file is properly configured');
  process.exit(1);
}

async function testRadiusStagingNonceBug() {
  console.log('🧪 Radius Staging Network Nonce Validation Test');
  console.log('===============================================\n');

  const provider = new ethers.providers.JsonRpcProvider(RADIUS_STAGING_RPC);
  
  try {
    // Get current network and account state
    const network = await provider.getNetwork();
    const blockNumber = await provider.getBlockNumber();
    
    console.log(`🌐 Network: ${network.name} (Chain ID: ${network.chainId})`);
    console.log(`📦 Block Number: ${blockNumber}`);
    console.log(`🏭 Test Contract: ${TEST_CONTRACT}`);
    console.log(`👤 Test Account: ${TEST_ACCOUNT}\n`);

    // Test 1: eth_call without 'from' field (should work on all networks)
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

    // Test 2: eth_call with 'from' field (SHOULD work on Staging - no nonce bug)
    console.log('📞 Test 2: eth_call WITH from field');
    console.log('Expected: ✅ SUCCESS (should work - no nonce bug)');
    console.log('Staging Expected: ✅ SUCCESS (bug should be fixed)');
    try {
      const result2 = await provider.call({
        to: TEST_CONTRACT,
        data: OWNER_SELECTOR,
        from: TEST_ACCOUNT
      });
      console.log('✅ PASS: Call succeeded - Staging network is working correctly!');
      console.log(`   Result: ${result2}\n`);
    } catch (err) {
      if (err.message.includes('nonce')) {
        console.log('❌ BUG STILL PRESENT: Nonce validation error on read-only operation');
        console.log(`   Error: ${err.error?.data || 'nonce validation error'}`);
        console.log('   🚨 Staging network still has the nonce bug!\n');
      } else {
        console.log('❌ DIFFERENT ERROR: Not the expected nonce bug');
        console.log(`   Error: ${err.message}\n`);
      }
    }

    // Test 3: eth_estimateGas (SHOULD work on Staging - no nonce bug)
    console.log('⛽ Test 3: eth_estimateGas');
    console.log('Expected: ✅ SUCCESS (should return gas estimate)');
    console.log('Staging Expected: ✅ SUCCESS (bug should be fixed)');
    try {
      const gasEstimate = await provider.estimateGas({
        to: TEST_CONTRACT,
        data: OWNER_SELECTOR,
        from: TEST_ACCOUNT
      });
      console.log('✅ PASS: Gas estimation succeeded - Staging network is working correctly!');
      console.log(`   Gas Estimate: ${gasEstimate.toString()}\n`);
    } catch (err) {
      if (err.message.includes('nonce')) {
        console.log('❌ BUG STILL PRESENT: Nonce validation error on gas estimation');
        console.log(`   Error: ${err.error?.data || 'nonce validation error'}`);
        console.log('   🚨 Staging network still has the nonce bug!\n');
      } else {
        console.log('❌ DIFFERENT ERROR: Not the expected nonce bug');
        console.log(`   Error: ${err.message}\n`);
      }
    }

    // Summary
    console.log('📋 SUMMARY');
    console.log('==========');
    console.log('This test verifies that Radius Staging network has fixed:');
    console.log('• eth_call operations when "from" field is present');
    console.log('• eth_estimateGas operations');
    console.log('');
    console.log('If both tests pass, we can use vanilla Uniswap deployment without workarounds.');
    console.log('If tests fail, the staging network still has the nonce bug.');
    console.log('');
    console.log('============================================================');
    console.log('📋 NEXT STEPS:');
    console.log('============================================================');
    console.log('');
    console.log('If tests PASSED ✅:');
    console.log('1️⃣  Deploy Uniswap V3 (vanilla deployment):');
    console.log('    npm run deploy-staging');
    console.log('');
    console.log('2️⃣  After deployment, update environment:');
    console.log('    npm run update-env');
    console.log('');
    console.log('If tests FAILED ❌:');
    console.log('1️⃣  Report to Radius team that staging still has nonce bug');
    console.log('2️⃣  Fall back to main Radius with workarounds:');
    console.log('    npm run switch-to-radius-testnet');
    console.log('');
    console.log('💡 Staging success proves vanilla deployment works when bug is fixed!');
    console.log('');

  } catch (err) {
    console.log(`❌ Network connection failed: ${err.message}`);
    console.log('Make sure to:');
    console.log('1. Run: npm run switch-to-radius-staging');
    console.log('2. Configure your .env.radius-staging file with valid credentials');
    console.log('3. Deploy contracts first if testing against specific contracts');
  }
}

// Run the test
if (require.main === module) {
  testRadiusStagingNonceBug().catch(console.error);
}

module.exports = { testRadiusStagingNonceBug }; 