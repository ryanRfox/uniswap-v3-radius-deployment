#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Detect current network from .env file
function detectNetwork() {
  if (!fs.existsSync('.env')) {
    console.error('❌ Error: No .env file found. Please switch to a network first.');
    process.exit(1);
  }
  
  const envContent = fs.readFileSync('.env', 'utf8');
  
  if (envContent.includes('Anvil Local')) {
    return {
      name: 'Anvil',
      stateFile: 'uniswap-v3-deployment-state.json',
      envFile: '.env.anvil'
    };
  } else if (envContent.includes('Base Sepolia')) {
    return {
      name: 'Base Sepolia',
      stateFile: 'uniswap-v3-deployment-state.json',
      envFile: '.env.base-sepolia'
    };
  } else if (envContent.includes('Radius Testnet')) {
    return {
      name: 'Radius Testnet',
      stateFile: 'uniswap-v3-deployment-state.json',
      envFile: '.env.radius-testnet'
    };
  } else if (envContent.includes('Radius Staging')) {
    return {
      name: 'Radius Staging',
      stateFile: 'uniswap-v3-deployment-state.json',
      envFile: '.env.radius-staging'
    };
  } else {
    console.error('❌ Error: Could not detect network from .env file');
    console.error('File content:', envContent.substring(0, 200) + '...');
    process.exit(1);
  }
}

const network = detectNetwork();
const STATE_FILE = network.stateFile;
const ENV_FILE = network.envFile;

function main() {
  console.log(`🔄 Updating ${ENV_FILE} with deployed contract addresses...`);

  // Check if state file exists
  if (!fs.existsSync(STATE_FILE)) {
    console.error('❌ Error: Deployment state file not found:', STATE_FILE);
    console.error('   Please run deployment first: npm run deploy');
    process.exit(1);
  }

  // Check if env file exists
  if (!fs.existsSync(ENV_FILE)) {
    console.error('❌ Error: Environment file not found:', ENV_FILE);
    process.exit(1);
  }

  try {
    // Read deployment state
    const stateContent = fs.readFileSync(STATE_FILE, 'utf8');
    const state = JSON.parse(stateContent);

    // Read current env file
    const envContent = fs.readFileSync(ENV_FILE, 'utf8');

    // Create mapping of deployment state to env variables
    const updates = {};
    
    // Core contract addresses
    if (state.v3CoreFactoryAddress) {
      updates.FACTORY_ADDRESS = state.v3CoreFactoryAddress;
    }
    
    if (state.swapRouter02Address) {
      updates.ROUTER_ADDRESS = state.swapRouter02Address;
    } else if (state.swapRouter02) {
      updates.ROUTER_ADDRESS = state.swapRouter02;
    }
    
    if (state.nonfungibleTokenPositionManagerAddress) {
      updates.POSITION_MANAGER_ADDRESS = state.nonfungibleTokenPositionManagerAddress;
    }
    
    if (state.quoterV2Address) {
      updates.QUOTER_ADDRESS = state.quoterV2Address;
    }
    
    if (state.weth9Address && state.weth9Address !== "0x0000000000000000000000000000000000000000") {
      updates.WETH_ADDRESS = state.weth9Address;
    }

    // Update env file content
    let updatedContent = envContent;
    let updatesApplied = 0;

    for (const [envVar, address] of Object.entries(updates)) {
      // Look for the variable in the file
      const regex = new RegExp(`^export ${envVar}=".*"$`, 'm');
      const replacement = `export ${envVar}="${address}"`;
      
      if (regex.test(updatedContent)) {
        updatedContent = updatedContent.replace(regex, replacement);
        updatesApplied++;
        console.log(`✅ Updated ${envVar}=${address}`);
      } else {
        // If variable doesn't exist, add it to the contract addresses section
        const contractSection = '# Contract Addresses (Set after deployment)';
        if (updatedContent.includes(contractSection)) {
          const sectionIndex = updatedContent.indexOf(contractSection);
          const nextSectionIndex = updatedContent.indexOf('\n# ', sectionIndex + 1);
          const insertIndex = nextSectionIndex === -1 ? updatedContent.length : nextSectionIndex;
          
          updatedContent = updatedContent.slice(0, insertIndex) + 
                          `export ${envVar}="${address}"\n` + 
                          updatedContent.slice(insertIndex);
          updatesApplied++;
          console.log(`✅ Added ${envVar}=${address}`);
        }
      }
    }

    // Write updated content back to file
    if (updatesApplied > 0) {
      fs.writeFileSync(ENV_FILE, updatedContent);
      console.log(`\n🎉 Successfully updated ${updatesApplied} contract addresses in ${ENV_FILE}`);
      console.log('\n📋 Updated addresses:');
      Object.entries(updates).forEach(([key, value]) => {
        console.log(`   ${key}: ${value}`);
      });
      console.log('\n💡 You can now source the updated environment file:');
      console.log(`   source ${ENV_FILE}`);
    } else {
      console.log('ℹ️  No updates were needed - all addresses are already set.');
    }

  } catch (error) {
    console.error('❌ Error updating environment file:', error.message);
    process.exit(1);
  }
}

// Run the script
main(); 