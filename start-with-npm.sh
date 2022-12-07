#!/bin/sh

install_nestjs_global() {
    echo "Installing nestjs global..."
    sudo npm install -g add @nestjs/cli
}

create_new_project() {
    echo "Creating new project..."
    nest new -p npm .
}

configure_commitlint_commitzend_husky() {
    echo "Installing coomitlint, commitzend and husky"
    npm install --save-dev commitizen
    npm install --save-dev @commitlint/config-conventional @commitlint/cli
    npm install --save-dev npe
    npm install --save-dev husky

    echo "Activate and configure husky"
    npx husky install
    npx husky add .husky/commit-msg "npx --no -- commitlint --edit ${1}"

    echo "Setting commitlint"
    echo "module.exports = {extends: ['@commitlint/config-conventional']}" >commitlint.config.js

    echo "Setting commitizen"
    commitizen init cz-conventional-changelog --save-dev --save-exact --force

    echo "Add command of commit in package.json"
    npe scripts.commit "git-cz"

    echo "Remove package npe"
    npm remove npe
}

create_dockerfile_dev() {
    echo "Create  Dockerfile dev"

    echo "FROM node:16.17.1-alpine

WORKDIR /home/node/app

ENV NODE_ENV development
ENV TZ America/Fortaleza

RUN npm install -g @nestjs/cli
RUN apk add --no-cache tzdata

CMD [ \"npm\", \"run\", \"start:dev\" ]
" >Dockerfile
}

create_dockerfile_prod() {
    echo "Create Dockerfile prod"
    echo "FROM node:16.17.1-alpine as builder

ENV NODE_ENV build

WORKDIR /home/node/app

COPY . .
RUN npm ci && npm run build && npm prune --production

######## Start a new stage from scratch ####### 
FROM node:16.17.1-alpine

ENV NODE_ENV production
ENV TZ America/Fortaleza

USER node
WORKDIR /home/node/app

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /home/node/app/dist ./dist
COPY --from=builder /home/node/app/package.json .
COPY --from=builder /home/node/app/package-lock.json .
COPY --from=builder /home/node/app/node_modules/ /home/node/app/node_modules/

RUN apk add --no-cache ca-certificates tzdata

# Command to run the executable
CMD [ \"node\", \"dist/main\" ]
" >Dockerfile.prod
}

ignore_folders() {
    echo "Ignore folders in dockerignore"
    echo "node_modules
deploy/release
dist
.git
.husky" >.dockerignore
}

install_package_to_config_absolute_import_path() {
    echo "Installing module alias..."
    npm install module-alias
    npm install --save-dev @types/module-alias
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
    npm install --save-dev eslint-plugin-import-helpers
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

settings_permissions() {
    echo "Settings permissions"
    chown -Rf 1000:1000 .
}

install_nestjs_global
create_new_project
configure_commitlint_commitzend_husky
create_dockerfile_dev
create_dockerfile_prod
ignore_folders
install_package_to_config_absolute_import_path
add_config_absolute_import_path
create_file_config_absolute_path
import_file_config_absolute_path
install_import_helpers
change_eslint_config
settings_permissions
