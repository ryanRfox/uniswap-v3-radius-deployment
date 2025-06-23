# Debug Materials

This branch contains engineering debugging materials for the Radius nonce validation bug.

## Contents

- `nonce-analysis/` - Technical analysis and testing materials
  - `NONCE-BUG.md` - Detailed technical analysis
  - `RADIUS-STAGING-SETUP.md` - Staging environment setup
  - `test-nonce-bug.js` - Testnet nonce validation test
  - `test-nonce-bug-staging.js` - Staging nonce validation test
  - `TYPESCRIPT-SOLUTION.md` - Historical solution documentation

## Usage

This branch is for engineering team reference and debugging purposes.
Do not merge these materials into the main public branch.

## Background

The Radius network initially had nonce validation bugs that affected standard Ethereum tooling.
These materials document the analysis, workarounds, and testing process for those issues.

## Running Tests

From the main branch, you can test nonce behavior:

```bash
# Switch to main branch and setup
git checkout main
npm run switch-to-radius-testnet

# Run nonce tests (from debug branch files)
git show debug:debug/nonce-analysis/test-nonce-bug.js > temp-test.js
node temp-test.js
rm temp-test.js
```

---

**Engineering Team Only** - Do not include in public repository
