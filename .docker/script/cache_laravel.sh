#!/bin/bash

. /usr/local/bin/colors.sh
. /usr/local/bin/signature.sh

if [ ! -f artisan ]; then
  echo -e "${RED}Erro: Este script deve ser executado no diretório raiz do Laravel (onde o arquivo artisan está localizado).${RESET}"
  exit 1
fi

echo -e  "${GREEN}Limpando todos os caches do Laravel...${RESET}"

php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan event:clear

echo -e "${GREEN}Otimizando novamente as configurações...${RESET}"

php artisan config:cache
php artisan route:cache
php artisan view:cache

echo -e "${GREEN}Executando composer dump-autoload...${RESET}"
composer dump-autoload

echo -e "${GREEN}Processo concluído com sucesso!${RESET}"
exit 0