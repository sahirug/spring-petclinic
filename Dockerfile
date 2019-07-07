FROM anapsix/alpine-java
LABEL maintainer="sahirug@gmail.com"
COPY target/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar /home/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar
CMD ["java", "-jar", "/home/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar"]