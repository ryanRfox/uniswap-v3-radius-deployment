#!/usr/bin/env node

const { execSync } = require('child_process');
const { existsSync } = require('fs');
const { join } = require('path');

const REPO_URL = 'https://github.com/Uniswap/deploy-v3.git';
const TARGET_DIR = 'uniswap-deploy-v3';

function runCommand(command, cwd) {
  try {
    console.log(`Running: ${command}`);
    execSync(command, { 
      stdio: 'inherit', 
      cwd: cwd || process.cwd() 
    });
  } catch (error) {
    console.error(`Failed to run: ${command}`);
    process.exit(1);
  }
}

function main() {
  console.log('🚀 Setting up Uniswap V3 deployment tool...\n');

  // Check if directory already exists
  if (existsSync(TARGET_DIR)) {
    console.log(`✅ Repository already exists at ${TARGET_DIR}`);
  } else {
    console.log(`📥 Cloning ${REPO_URL}...`);
    runCommand(`git clone ${REPO_URL} ${TARGET_DIR}`);
    console.log('✅ Repository cloned successfully');
  }

  // Install dependencies
  console.log('\n📦 Installing deployment tool dependencies...');
  const targetPath = join(process.cwd(), TARGET_DIR);
  runCommand('npm install', targetPath);
  
  console.log('\n🎉 Setup completed successfully!');
  console.log('\nNext steps:');
  console.log('  npm run check-balance  # Check your account balance');
  console.log('  npm run deploy         # Deploy Uniswap V3');
}

if (require.main === module) {
  main();
} 