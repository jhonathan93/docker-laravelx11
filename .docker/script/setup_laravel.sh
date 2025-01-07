#!/bin/bash

. /usr/local/bin/colors.sh
. /usr/local/bin/signature.sh

function print_message() {
  local color=$1
  local message=$2
  echo -e "\n${color}${message}${RESET}\n"
}

set -e

print_message "$GREEN" "Instalando o Laravel versão 11..."
composer create-project laravel/laravel=11.* . --prefer-dist

print_message "$GREEN" "Copiando o arquivo .env para o diretório do Laravel..."
cp /usr/local/bin/.env /var/www/html/.env

print_message "$GREEN" "Instalando as dependências do Composer..."
composer install --no-dev --optimize-autoloader

print_message "$GREEN" "Gerando chave de aplicativo..."
php artisan key:generate

print_message "$GREEN" "Executando as migrações no banco de dados..."
php artisan migrate --force

if php artisan list | grep -q 'install:api'; then
  print_message "$GREEN" "Instalando dependências do API do Laravel..."
  php artisan install:api
else
  print_message "$RED" "Comando 'install:api' não encontrado. Pulando esta etapa..."
fi

print_message "$GREEN" "Definindo permissões corretas para o Laravel..."
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

print_message "$GREEN" "Configuração concluída com sucesso!"

exec "$@"