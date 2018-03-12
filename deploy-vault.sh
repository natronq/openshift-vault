#!/bin/bash
set -e 
set -o pipefail

echo "Deploying PostgreSQL..."
oc new-app postgresql-persistent -p POSTGRESQL_DATABASE=backend -e POSTGRESQL_ADMIN_PASSWORD=somegeneratedpassword

echo "Deploying Vault..."
oc adm policy add-scc-to-user anyuid -z default
oc create configmap vault-config --from-file=vault-config=./vault/vault-config.json
oc create -f ./vault/vault.yml
oc create route reencrypt vault --port=8200 --service=vault

