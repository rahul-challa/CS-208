# Use a multi-arch base image for the build stage
FROM eclipse-temurin:17-jdk AS build
WORKDIR /workspace/app

# Copy Maven wrapper and source code
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src
# Build the application
RUN ./mvnw package -DskipTests

# Extract the JAR file
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

# Use a multi-arch base image for the runtime stage
FROM eclipse-temurin:17-jre
VOLUME /tmp

# Copy dependencies and application files from the build stage
ARG DEPENDENCY=/workspace/app/target/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

# Set the entry point
ENTRYPOINT ["java","-cp","app:app/lib/*","com.example.demo.DemoProjectApplication"]