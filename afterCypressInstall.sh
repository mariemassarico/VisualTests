#!/bin/bash

# Create cypress.env and cypress.env.example files, defaulting them to empty objects
touch cypress.env.example.json
echo '{
    "email": "{{CYPRESS_USER}}",
    "senha": "{{CYPRESS_PASS}}",
    "email2": "{{CYPRESS_USER2}}",
    "senha2": "{{CYPRESS_PASS2}}"
}' > cypress.env.example.json
