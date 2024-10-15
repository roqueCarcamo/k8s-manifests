FROM openjdk:17-slim
# Set timezone
ENV TZ="America/Bogota"

# Set the locale
ENV LANG es_CO.UTF-8
ENV LANGUAGE es_CO:es
ENV LC_ALL es_CO.UTF-8
VOLUME /tmp
COPY target/demo-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
