# Use an official OpenJDK image as the base image
FROM openjdk:11-jre-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the application jar file into the container
COPY your-java-application.jar /app/

# Expose any necessary ports (if your application requires it)
EXPOSE 8080

# Set the entry point to start the Java application
ENTRYPOINT ["java", "-jar", "your-java-application.jar"]

