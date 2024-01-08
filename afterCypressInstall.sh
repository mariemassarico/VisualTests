#!/bin/bash

# Install the visual Regression Tracker - VRT
npm install @visual-regression-tracker/agent-cypress --save-dev

# Install the configuration for to run
npm install -g git@github.com:mariemassarico/VisualTests.git

# Create cypress.env and cypress.env.example files, defaulting them to empty objects
touch cypress.env.example.json
echo '{
    "email": "{{CYPRESS_USER}}",
    "senha": "{{CYPRESS_PASS}}",
    "email2": "{{CYPRESS_USER2}}",
    "senha2": "{{CYPRESS_PASS2}}"
}' >cypress.env.example.json

cp cypress.env.example.json cypress.env.json

# create vrt.json for configurations of Visual Regression Tracker
echo '{
  "apiUrl": "http://localhost:4200",
  "apiKey": "DEFAULTUSERAPIKEYTOBECHANGED",
  "project": "soda-quality-desing-tests",
  "email": "visual-regression-tracker@example.com",
  "password": "123456",
  "branchName": "master",
  "enableSoftAssert": true
}' >vrt.json

# create vrt.json for configurations of Visual Regression Tracker

echo 'version: "3.8"
services:
  ui:
    image: visualregressiontracker/ui:${VRT_UI_VERSION}
    ports:
      - "${PORT}:8080"
    volumes:
      - ./imageUploads:/usr/share/nginx/html/static/imageUploads
    environment:
      REACT_APP_API_URL: ${REACT_APP_API_URL}
      VRT_VERSION: ${VRT_UI_VERSION}
      PORT: ${PORT}
    restart: always
  api:
    image: visualregressiontracker/api:${VRT_API_VERSION}
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
      JWT_SECRET: ${JWT_SECRET}
      JWT_LIFE_TIME: ${JWT_LIFE_TIME}
      APP_FRONTEND_URL: ${APP_FRONTEND_URL}
      BODY_PARSER_JSON_LIMIT: ${BODY_PARSER_JSON_LIMIT}
      ELASTIC_URL: ${ELASTIC_URL}
    ports:
      - "${APP_PORT}:3000"
    volumes:
      - ./imageUploads:/imageUploads
    depends_on:
      postgres:
        condition: service_healthy
    restart: always
  migration:
    image: visualregressiontracker/migration:${VRT_MIGRATION_VERSION}
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
    depends_on:
      postgres:
        condition: service_healthy
    restart: on-failure
  postgres:
    image: postgres:12
    restart: always
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    ports:
      - "${POSTGRES_PORT}:5432"
    expose:
      - "${POSTGRES_PORT}"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "pg_isready -d $$POSTGRES_DB -U $$POSTGRES_USER"
        ]
      interval: 10s
      timeout: 120s
      retries: 10
volumes:
  postgres_data:' >docker-compose.yaml

# create the env.json

echo '.env:
## Logging
# https://www.elastic.co/guide/en/elastic-stack/7.14/overview.html
ELK_VERSION=7.14.1
ELASTIC_URL=http://localhost:9200

## VRT version
VRT_UI_VERSION=5.0.2
VRT_API_VERSION=5.0.4
VRT_MIGRATION_VERSION=5.0.1

## Frontend

# direct URL to backend with port (same as APP_PORT)
REACT_APP_API_URL=http://localhost:4200
# frontend port
PORT=8080

## Backend

# direct URL to frontend with port (same as PORT)
APP_FRONTEND_URL=http://localhost:8080
# backend port
APP_PORT=4200
# seed to generate JWT
JWT_SECRET='jwtPrivateKey'
# user session lifetime
JWT_LIFE_TIME=1d
# max image size to upload
BODY_PARSER_JSON_LIMIT="5mb"

## DB

POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=vrt_db' >.env

# Changes in Cypress configuration for running

echo 'const { defineConfig } = require('cypress')
const { addVisualRegressionTrackerPlugin } = require('@visual-regression-tracker/agent-cypress/dist/plugin')

module.exports = defineConfig({
  e2e: {
    watchForFileChanges: false,
    viewportHeight: 800,
    viewportWidth: 1440,
    defaultCommandTimeout: 20000,
    experimentalSessionAndOrigin: true,
    video: false,
    screenshotOnRunFailure: false,
    setupNodeEvents(on, config) {
      addVisualRegressionTrackerPlugin(on, config)
    }
  }
})' >cypress.config.js

# create commands and add VRT plugin in this project
rm cypress/support/commands.js e2e.js
cd cypress/support

echo "Cypress.Commands.add('vrt', title => {
    cy.vrtStart()
    cy.vrtTrack(title)
    cy.vrtStop()
})

Cypress.Commands.add('login', (yourURL,email, senha) => {
    cy.session([yourURL, email, senha], () => {
        cy.visit(yourURL)
        cy.get('.redirect-button').click()
        cy.get('#username').type(email)
        cy.get('#password').type(senha, {log: false})
        cy.get('#kc-login').click()
    })
})" >commands.js

echo "import {
    addVrtTrackCommand,
    addVrtStartCommand,
    addVrtStopCommand,
    addVrtTrackBufferCommand,
    addVrtTrackBase64Command,
} from '@visual-regression-tracker/agent-cypress/dist/commands'

addVrtStartCommand()
addVrtStopCommand()
addVrtTrackCommand()
addVrtTrackBufferCommand()
addVrtTrackBase64Command()

import './commands'" >e2e.js
