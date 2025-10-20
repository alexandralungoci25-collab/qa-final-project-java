FROM maven:3.9.9-eclipse-temurin-21
WORKDIR /workspace
COPY pom.xml ./
RUN mvn -B -ntp -q dependency:go-offline
COPY . ./
CMD ["mvn", "-B", "-ntp", "test"]
