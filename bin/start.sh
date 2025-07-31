#!/bin/bash

# shellcheck disable=SC2162

source ./.docker/script/core.sh

CONTAINER_NAME="docker-laravel-mysql-1"

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo -e "${GREEN}${WHITE_CHECK} O container '${CONTAINER_NAME}' já está configurado, Pulando a configuração interativa.${RESET}"
  echo -e "\n"
else
  echo -e "${GREEN}
  Configuração Interativa para o MySQL no Docker Compose e .env!
  Por favor, insira os valores para o serviço MySQL:
  ${RESET}"

  read -p "Nome do banco de dados MySQL (padrão: laravel): " MYSQL_DATABASE
  MYSQL_DATABASE=${MYSQL_DATABASE:-laravel}

  read -p "Usuário do banco de dados MySQL (padrão: laravel): " MYSQL_USER
  MYSQL_USER=${MYSQL_USER:-laravel}

  read -p "Senha do usuário MySQL (padrão: admin123): " MYSQL_PASSWORD
  MYSQL_PASSWORD=${MYSQL_PASSWORD:-admin123}

  read -p "Senha do root MySQL (padrão: admin123): " MYSQL_ROOT_PASSWORD
  MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-admin123}

  awk -v database="${MYSQL_DATABASE}" \
      -v user="${MYSQL_USER}" \
      -v password="${MYSQL_PASSWORD}" \
      -v root_password="${MYSQL_ROOT_PASSWORD}" \
  'BEGIN {found_mysql=0}
  {
    if ($0 ~ /mysql:/) { found_mysql=1 }
    if (found_mysql) {
      if ($0 ~ /MYSQL_DATABASE:/) $0 = "      MYSQL_DATABASE: " database
      if ($0 ~ /MYSQL_USER:/) $0 = "      MYSQL_USER: " user
      if ($0 ~ /MYSQL_PASSWORD:/) $0 = "      MYSQL_PASSWORD: " password
      if ($0 ~ /MYSQL_ROOT_PASSWORD:/) $0 = "      MYSQL_ROOT_PASSWORD: " root_password
      if ($0 ~ /^[^ ]/) { found_mysql=0 } # Sai do bloco do MySQL
    }
    print
  }' docker-compose.yml > docker-compose.temp && mv docker-compose.temp docker-compose.yml

  ENV_FILE="./.docker/config/.env"

  sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${MYSQL_DATABASE}/" "$ENV_FILE"
  sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${MYSQL_USER}/" "$ENV_FILE"
  sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=${MYSQL_PASSWORD}/" "$ENV_FILE"

  echo -e "\n"
  echo -e "${GREEN}${WHITE_CHECK} Configuração do serviço MySQL atualizado com sucesso no docker-compose.yml e .env!${RESET}"
  echo -e "\n"
fi

detect_docker_compose() {
  if command -v docker-compose >/dev/null 2>&1; then
    echo "docker-compose"
  elif docker compose version >/dev/null 2>&1; then
    echo "docker compose"
  else
    echo "❌ Erro: Docker Compose não encontrado. Instale o Docker Compose." >&2
    exit 1
  fi
}

DOCKER_COMPOSE_CMD=$(detect_docker_compose)

echo -e "${GREEN}ℹ️  Usando comando: ${DOCKER_COMPOSE_CMD}${RESET}"

$DOCKER_COMPOSE_CMD up -d

echo -e "\n"
echo -e "${GREEN}${WHITE_CHECK} Configuração concluída! Todos os serviços foram iniciados com sucesso!${RESET}"
echo -e "\n"

source ./.docker/script/signature.sh