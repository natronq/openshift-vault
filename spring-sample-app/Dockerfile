FROM openjdk:8-jre
MAINTAINER Yannick.Pobiega <yannick.pobiega@nttdata.com>

ADD target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT exec java $JAVA_OPTS -jar app.jar

