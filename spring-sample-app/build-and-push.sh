#!/bin/bash
mvn -DskipTests clean install
docker build -t moravit/spring-sample-app:latest .
docker push moravit/spring-sample-app:latest
