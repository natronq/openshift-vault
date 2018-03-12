#!/bin/bash
set -e
set -o pipefail

function vault_enable_postgres_backend {
  echo "Enabling postgres backend..."
  vault secrets enable database
  # Create a database configuration with a superuser on database 'backend'
  vault write database/config/postgres-db plugin_name=postgresql-database-plugin allowed_roles="*" connection_url="postgresql://postgres:somegeneratedpassword@postgresql:5432/backend?sslmode=disable"
  # Create a role which creates a PostgreSQL role with all permissions on database 'backend'
  vault write database/roles/backend db_name=postgres-db    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"{{name}}\""  default_ttl="5m"    max_ttl="9000h"
  echo "Writing sample secret..."
  # Write a sample generic secret for later retrieval
  vault write secret/backend password=pwd  
}

function vault_enable_kubernets_auth {
  echo "Creating service account for Vault..."
  oc create sa vault-auth
  # Add policy to allow TokenReview requests from vault
  oc adm policy add-cluster-role-to-user system:auth-delegator -z vault-auth
  # Get the JWT token for the servie account
  reviewer_service_account_jwt=$(oc serviceaccounts get-token vault-auth)
  # Get the CA certificate for our cluster
  pod=$(oc get pods -n $(oc project -q) | grep vault | awk '{print $1}')
  oc exec $pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt >> ca.crt
  echo "Enabling kubernetes auth backend..."
  vault auth enable kubernetes
  # Use the JWT token and CA certificate to create a kubernetes authentication configuration
  vault write auth/kubernetes/config token_reviewer_jwt=$reviewer_service_account_jwt kubernetes_host=https://kubernetes.default.svc.cluster.local:443 kubernetes_ca_cert=@ca.crt 
  rm ca.crt
  echo "Creating sample policy with name 'backend'"
  vault policy-write backend vault/backend-policy.hcl 
  echo "Creating sample role with name 'backend' bound to namespace 'secret-management'"
  vault write auth/kubernetes/role/backend bound_service_account_names=default bound_service_account_namespaces=secret-management policies=backend ttl=2h
}

export VAULT_SKIP_VERIFY=true
vault_enable_kubernets_auth
vault_enable_postgres_backend