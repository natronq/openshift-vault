# Vault integration with OpenShift and Spring Cloud

This repository demonstrates how to deploy HashiCorps Vault on OpenShift and leverage service accounts with Spring Cloud to claim database credentials dynamically from the Vault.

## Getting started

1. Create a project

    ```bash
    $ oc new-project secret-management
    ```

2. Deploy a database and HashiCorp's Vault

    ```bash
    $ ./deploy-vault.sh

    Deploying PostgreSQL...
    --> Deploying template "openshift/postgresql-persistent" to project secret-management
    [....]
    Deploying Vault...
    scc "anyuid" added to: ["system:serviceaccount:secret-management:default"]
    configmap "vault-config" created
    service "vault" created
    deploymentconfig "vault" created
    persistentvolumeclaim "vault-file-backend" created
    route "vault" created
    ```

3. Initialize and unseal vault

    ```bash
    $ export VAULT_ADDR="https://$(oc get route vault -o jsonpath={.spec.host})"
    $ vault operator init -tls-skip-verify -key-shares=1 -key-threshold=1

    Unseal Key 1: t7grHZRi8dLcNDe04X8KcuixjEdzR5xXmpXE1N2TUo4=

    Initial Root Token: f4949362-6e88-0980-c604-51ce7d62c4eb

    Vault initialized with 1 key shares and a key threshold of 1. Please securely
    distribute the key shares printed above. When the Vault is re-sealed,
    restarted, or stopped, you must supply at least 1 of these keys to unseal it
    before it can start servicing requests.

    Vault does not store the generated master key. Without at least 1 key to
    reconstruct the master key, Vault will remain permanently sealed!

    It is possible to generate new unseal keys, provided you have a quorum of
    existing unseal keys shares. See "vault rekey" for more information.
    ```

    Take not of the generated key and root token and export them as environment variables
    to unseal the vault.

    ```bash
    $ export KEYS=t7grHZRi8dLcNDe04X8KcuixjEdzR5xXmpXE1N2TUo4=
    $ export ROOT_TOKEN=f4949362-6e88-0980-c604-51ce7d62c4eb
    $ vault operator unseal -tls-skip-verify $KEYS

    Key             Value
    ---             -----
    Seal Type       shamir
    Sealed          false
    Total Shares    1
    Threshold       1
    Version         0.9.5
    Cluster Name    vault-cluster-e566d4ca
    Cluster ID      369a2073-8480-f8e1-cb30-a059fcc7e650
    HA Enabled      false
    ```

4. Configure vault

    ```bash
    $ vault login -tls-skip-verify $ROOT_TOKEN 
    $ ./init-vault.sh

    Creating service account for Vault...
    serviceaccount "vault-auth" created
    cluster role "system:auth-delegator" added: "vault-auth"
    Enabling kubernetes auth backend...
    Success! Enabled kubernetes auth method at: kubernetes/
    Success! Data written to: auth/kubernetes/config
    Creating sample policy with name 'backend'
    WARNING! The "vault policy-write" command is deprecated. Please use "vault
    policy write" instead. This command will be removed in Vault 0.11 (or later).

    Success! Uploaded policy: backend
    Creating sample role with name 'backend' bound to namespace 'secret-management'
    Success! Data written to: auth/kubernetes/role/backend
    Enabling postgres backend...
    Success! Enabled the database secrets engine at: database/
    WARNING! The following warnings were returned from Vault:

    * Read access to this endpoint should be controlled via ACLs as it will
    return the connection details as is, including passwords, if any.

    Success! Data written to: database/roles/backend
    Writing sample secret...
    Success! Data written to: secret/backend
    ```

5. Deploy sample application

    ```bash
    ./deploy-app.sh

    Deploying sample application...
    service "spring-sample-app" created
    deploymentconfig "spring-sample-app" created
    route "spring-sample-app" exposed
    ```

6. Test the integration

    ```bash
    $ ./test.sh

    Testing vault integration...
    Key                                       Value
    ---                                       -----
    token                                     a476fa24-bebd-7b38-c9c2-4483e6722958
    token_accessor                            898921e3-1081-b353-5c34-824ef7bea809
    token_duration                            2h
    token_renewable                           true
    token_policies                            [backend default]
    token_meta_role                           backend
    token_meta_service_account_name           default
    token_meta_service_account_namespace      secret-management
    token_meta_service_account_secret_name    default-token-mqknc
    token_meta_service_account_uid            d88455df-2779-11e8-9d97-06f99210ef0e
    {"status":"UP"}my secret ispwd{"id":null,"value":"40","respText":"Success"}%
    ```