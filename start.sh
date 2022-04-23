#!/bin/sh

# Install yarn global
sudo npm install -g yarn

# Install nestjs-cli global
sudo yarn global add @nestjs/cli 

# Create new project nest
nest new -p yarn .

# Install commitlint cli and conventional config
yarn add @commitlint/config-conventional @commitlint/cli -D

# Configure commitlint to use conventional config
echo "module.exports = {extends: ['@commitlint/config-conventional']}" > commitlint.config.js

# install husky
yarn add husky -D

# Activate hooks
yarn husky install

# Add hook
yarn husky add .husky/commit-msg 'yarn commitlint --edit "$1"'

# Install commitizen
yarn add commitizen -D

# Init commitizen
yarn commitizen init cz-conventional-changelog --yarn --dev --exact

yarn add npe
yarn npe scripts.commit "git-cz"
yarn remove npe

chown -Rf 1000:1000 .











