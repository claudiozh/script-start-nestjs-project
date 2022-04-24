#!/bin/sh

install_yarn() {
    echo "Installing yarn..."
    sudo npm install -g yarn
}

install_nestjs() {
    echo "Installing nestjs..."
    sudo yarn global add @nestjs/cli
}

create_new_project() {
    echo "Creating new project..."
    nest new -p yarn .
}

install_commitlint() {
    echo "Installing commitlint..."
    yarn add @commitlint/config-conventional @commitlint/cli -D

    # Configure commitlint to use conventional config
    echo "module.exports = {extends: ['@commitlint/config-conventional']}" >commitlint.config.js
}

install_commitzen() {
    echo "Installing commitizen..."
    # Install commitizen
    yarn add commitizen -D

    # Init commitizen
    yarn commitizen init cz-conventional-changelog --yarn --dev --exact
}

install_husky() {
    echo "Installing husky..."
    yarn add husky -D

    # Activate hooks
    yarn husky install

    # Add hook
    yarn husky add .husky/commit-msg 'yarn commitlint --edit "$1"'
}

add_command_to_commit() {
    echo "Modifying package.json..."
    yarn add npe
    yarn npe scripts.commit "git-cz"
    yarn remove npe
}

install_package_to_config_absolute_import_path() {
    echo "Installing module alias..."
    yarn add module-alias
    yarn add @types/module-alias -D
}

add_config_absolute_import_path() {
    echo "Modifying tsconfig.json..."
    echo '{
    "compilerOptions": {
        "module": "commonjs",
        "declaration": true,
        "removeComments": true,
        "emitDecoratorMetadata": true,
        "experimentalDecorators": true,
        "allowSyntheticDefaultImports": true,
        "target": "es2017",
        "sourceMap": true,
        "outDir": "./dist",
        "baseUrl": "./",
        "incremental": true,
        "skipLibCheck": true,
        "strictNullChecks": false,
        "noImplicitAny": false,
        "strictBindCallApply": false,
        "forceConsistentCasingInFileNames": false,
        "noFallthroughCasesInSwitch": false,
        "paths": {
            "@src/*": ["src/*"]
        },
        "esModuleInterop": true
    }
}' >tsconfig.json
}

create_file_config_absolute_path() {
    echo "Create file config absolute path..."

    mkdir ./src/config

    echo "import moduleAlias from 'module-alias';
import path from 'path';

const rootPath = path.resolve(__dirname, '..', '..', 'dist');
    
moduleAlias.addAliases({
    '@src': rootPath,
});" >./src/config/aliases.ts
}

import_file_config_absolute_path() {
    echo "Import file config absolute path..."

    value=$(
        echo -n "import './config/aliases';\n"
        cat ./src/main.ts
    )
    echo "$value" >./src/main.ts
}

install_import_helpers() {
    yarn add eslint-plugin-import-helpers -D
}

change_eslint_config() {
    echo "Modifying eslint config..."
    echo "module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: 'tsconfig.json',
    sourceType: 'module',
  },
  plugins: [
    '@typescript-eslint/eslint-plugin',
    'import-helpers',
  ],
  extends: [
    'plugin:@typescript-eslint/recommended',
    'plugin:prettier/recommended',
  ],
  root: true,
  env: {
    node: true,
    jest: true,
  },
  ignorePatterns: ['.eslintrc.js'],
  rules: {
    '@typescript-eslint/interface-name-prefix': 'off',
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
    'import-helpers/order-imports': [
      'warn',
      {
        'newlinesBetween': 'always',
        'groups': [
          'module',
          '/^@//',
          ['parent', 'sibling', 'index']
        ],
        'alphabetize': { 'order': 'asc', 'ignoreCase': true }
      }
    ],
  },
};" >.eslintrc.js
}

ignore_dot_env() {
    echo "Ignore .env file..."
    echo "\n.env" >>.gitignore
}

add_permissions() {
    echo "Adding permissions..."
    chown -Rf 1000:1000 .
}

install_yarn
install_nestjs
create_new_project
install_commitlint
install_commitzen
install_husky
install_import_helpers
add_command_to_commit
install_package_to_config_absolute_import_path
add_config_absolute_import_path
create_file_config_absolute_path
import_file_config_absolute_path
ignore_dot_env
change_eslint_config
add_permissions
