# ── Build stage ──────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn package -DskipTests -q

# ── Runtime stage ─────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/tellix-backend-*.jar app.jar

# Usuario no-root
RUN addgroup -S tellix && adduser -S tellix -G tellix
USER tellix

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
