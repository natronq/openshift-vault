#!/bin/bash
set -e
set -o pipefail

echo "Testing vault integration..."
# Test vault login
vault write auth/kubernetes/login role=backend jwt=$(oc serviceaccounts get-token default -n secret-management)
# Test service
route=$(oc get route spring-sample-app -o jsonpath={.spec.host})
curl http://$route/health 
curl http://$route/secret 
curl http://$route/addValue -H "Content-Type: application/json" -X POST -d '{"value":"40"}'
curl http://$route/value -H "Content-Type: application/json" -X POST -d '{"value":"40"}'