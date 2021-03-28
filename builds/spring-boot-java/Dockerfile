############################
# STEP 1 build executable packages
############################
FROM maven:3.6.0-jdk-11-slim AS builder

COPY src /home/app/src
COPY pom.xml /home/app

RUN mvn -f /home/app/pom.xml clean package

#############################
## STEP 2 build a small image
#############################
FROM openjdk:11-jre-slim

COPY src/main/resources/credentials-dev.p12 /home/app/credentials-dev.p12
COPY --from=builder /home/app/target/*.jar spring-boot-application.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","spring-boot-application.jar"]