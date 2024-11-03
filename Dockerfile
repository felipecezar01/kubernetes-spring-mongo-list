# Etapa 1: Compilação
# Usa uma imagem com JDK 21 para compilar a aplicação
FROM eclipse-temurin:21 AS build

# Instala o Maven manualmente, já que não estamos usando uma imagem com Maven embutido
RUN apt-get update && \
    apt-get install -y maven && \
    rm -rf /var/lib/apt/lists/*

# Define o diretório de trabalho
WORKDIR /app

# Copia o arquivo pom.xml e baixa as dependências
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copia o código fonte para dentro do contêiner
COPY src ./src

# Compila o projeto e gera o arquivo JAR
RUN mvn package -DskipTests

# Etapa 2: Execução
# Usa uma imagem JRE com Java 21 para rodar o JAR
FROM eclipse-temurin:21-jre

# Define o diretório de trabalho no contêiner
WORKDIR /app

# Copia o JAR compilado da etapa de build
COPY --from=build /app/target/*.jar app.jar

# Exponha a porta 8080, que o Spring Boot usa por padrão
EXPOSE 8080

# Define o comando para rodar a aplicação
ENTRYPOINT ["java", "-jar", "app.jar"]
