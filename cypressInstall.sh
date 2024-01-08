#!/usr/bin/env bash

# Establish a project directory and navigate to it.
mkdir $1
cd $1
# Initialize git and .gitignore
git init
touch .gitignore
echo '{
    .env
    cypress.env.json
    node_modules/
    cypress/downloads/
    cypress/screenshots/
}' >.gitignore
# Initialize NPM
npm init -y
# Changes at package.json

# Variável para o autor
author_name="$2"

# Atualizar o conteúdo do package.json sem jq
sed -i 's/"description": ""/"description": "Experiment with visual regression tracker and cypress for visual design tests"/' package.json
sed -i '/"test": "echo /d' package.json
sed -i 's/"scripts": {/"scripts": {\
    "cy:open": "cypress open",\
    "test": "cypress run",\
    "test:chrome": "cypress run --browser chrome",\
    "test:firefox": "cypress run --browser firefox",\
    "test:edge": "cypress run --browser edge"/' package.json
sed -i 's/"keywords": \[\]/"keywords": \[\
    "visual regression testing",\
    "visual-regression-tracker",\
    "cypress.io"\
\]/' package.json
sed -i 's/"author": ""/"author": "'"$author_name"'"/' package.json
sed -i 's/"license": "ISC"/"license": "MIT"/' package.json

# Install Cypress (if a version is specified, it will be installed; otherwise, the latest version will be installed).
if [ "$3" ]; then
  npm i cypress@"$3" -D
else
  npm i cypress -D
fi
# Open Cypress for create your directories
npx cypress open
