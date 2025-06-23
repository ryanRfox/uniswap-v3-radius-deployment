#!/bin/bash

echo "💰 Checking wallet balance..."
echo ""

# Run the balance check
source .env && node -e "
const { ethers } = require('ethers'); 
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL); 
const wallet = new ethers.Wallet(process.env.DEPLOYER_KEY, provider); 
wallet.getBalance().then(b => { 
  const balance = ethers.utils.formatEther(b); 
  console.log('💰 Balance:', balance, 'ETH'); 
  console.log('📧 Address:', wallet.address);
  console.log('🌐 Network:', process.env.NETWORK_NAME || 'Unknown');
  console.log('🔗 RPC URL:', process.env.RPC_URL);
  console.log('');
  
  if (parseFloat(balance) < 0.1) { 
    console.log('❌ INSUFFICIENT BALANCE - Need more ETH for deployment');
    console.log('');
    console.log('============================================================');
    console.log('📋 NEXT STEPS:');
    console.log('============================================================');
    console.log('');
    console.log('💸 Get testnet ETH from faucets:');
         if (process.env.RPC_URL && process.env.RPC_URL.includes('base')) {
       console.log('    📱 Base Sepolia: https://faucet.quicknode.com/base/sepolia');
     } else if (process.env.RPC_URL && process.env.RPC_URL.includes('staging.tryradi.us')) {
       console.log('    📱 Radius Staging: https://stg.tryradi.us/dashboard/faucet');
     } else if (process.env.RPC_URL && process.env.RPC_URL.includes('tryradi.us')) {
       console.log('    📱 Radius: https://testnet.tryradi.us/dashboard/faucet');
     } else if (process.env.RPC_URL && process.env.RPC_URL.includes('localhost')) {
      console.log('    💰 Anvil: Unlimited test ETH available');
    }
    console.log('');
    console.log('🔄 After getting ETH, check balance again:');
    console.log('    npm run check-balance');
    console.log('');
  } else if (parseFloat(balance) < 0.5) { 
    console.log('⚠️  LOW BALANCE - May need more ETH for full deployment');
    console.log('');
    console.log('============================================================');
    console.log('📋 NEXT STEPS:');
    console.log('============================================================');
    console.log('');
    console.log('✅ You can proceed, but consider getting more ETH for safety');
    console.log('');
    console.log('1️⃣  Test deployment tool:');
    console.log('    npm run test-deploy-tool');
    console.log('');
    console.log('2️⃣  Start deployment:');
    console.log('    npm run deploy');
    console.log('');
    console.log('💡 TIP: Full deployment needs ~0.5 ETH for gas fees');
    console.log('');
  } else { 
    console.log('✅ SUFFICIENT BALANCE - Ready for deployment!');
    console.log('');
    console.log('============================================================');
    console.log('📋 NEXT STEPS:');
    console.log('============================================================');
    console.log('');
    console.log('1️⃣  Test deployment tool:');
    console.log('    npm run test-deploy-tool');
    console.log('');
    console.log('2️⃣  Start deployment:');
    console.log('    npm run deploy');
    console.log('');
    console.log('🎉 You have enough ETH for full Uniswap V3 deployment!');
    console.log('');
  } 
}).catch(err => {
  console.error('❌ Balance check failed:', err.message);
  console.log('');
  console.log('============================================================');
  console.log('📋 TROUBLESHOOTING:');
  console.log('============================================================');
  console.log('');
  console.log('1️⃣  Check network connection:');
  console.log('    source .env && echo \"RPC: \$RPC_URL\"');
  console.log('');
  console.log('2️⃣  Verify private key is valid:');
  console.log('    source .env && echo \"Address: \$DEPLOYER_ADDRESS\"');
  console.log('');
  console.log('3️⃣  Switch to a working network:');
  console.log('    npm run switch-to-anvil  # Local testing');
  console.log('');
});" 