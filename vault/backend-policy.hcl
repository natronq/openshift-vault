path "database/creds/backend" {
    capabilities = ["read", "list"]
}
path "secret/backend" { 
    capabilities = ["read", "list"] 
}
path "secret/application" { 
    capabilities = ["read", "list"] 
}
path "sys/leases/renew" {
    capabilities = ["update"] 
}

path "sys/renew/*" {
    policy = "write"
}