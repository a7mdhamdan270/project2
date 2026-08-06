#!/bin/bash

VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN="${VAULT_TOKEN}"
SECRET_PATH='secret/expense_tracker'
ENV_FILE='./backend/.env'

echo "Retrieving secrets from Vault..."


SECRETS=$(docker exec -e VAULT_ADDR="$VAULT_ADDR" -e VAULT_TOKEN="$VAULT_TOKEN" vault vault kv get -format=json secret/expense_tracker 2>/dev/null)

if [ -z "$SECRETS" ]; then
  echo "Failed to retrieve secrets from Vault."
  exit 1
fi

echo "Saving secrets to $ENV_FILE..."

echo "$SECRETS" | jq -r '.data.data | to_entries[] | .key + "=" + (.value|tostring)' > "$ENV_FILE"

if [ $? -eq 0 ]; then
  echo "Successfully created $ENV_FILE!"
  echo "Running Docker containers..."
  docker compose up -d
else
  echo "Failed to process secrets with jq."
  exit 1
fi
