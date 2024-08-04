#!/bin/bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 20

# async
cd /tmp/src/async
zip -r /tmp/zips/async.zip .

# Check
cd /tmp/src/check
rm -rf node_modules
rm -f package-lock.json
npm i
zip -r /tmp/zips/check.zip .

# metrics
cd /tmp/src/metrics
# rm -rf node_modules
# rm -f package-lock.json
# npm i
zip -r /tmp/zips/metrics.zip .

# reporter
cd /tmp/src/reporter
# rm -rf node_modules
# rm -f package-lock.json
# npm i
zip -r /tmp/zips/reporter.zip .