echo "Deploying sample application..."
oc create -f spring-sample-app/spring-sample-app.yml
oc expose svc spring-sample-app