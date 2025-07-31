#!/bin/bash

. /usr/local/bin/core.sh
. /usr/local/bin/signature.sh

if [ ! -f artisan ]; then
  print_message "$RED" "${EMOJI_FAIL} Erro: Este script deve ser executado no diretório raiz do Laravel (onde o arquivo artisan está localizado)."
  exit 1
fi

print_message "$GREEN" "${EMOJI_HOURGLASS} Limpando todos os caches do Laravel..."

php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan event:clear

print_message "$GREEN" "${EMOJI_HOURGLASS} Otimizando novamente as configurações..."

php artisan config:cache
php artisan route:cache
php artisan view:cache

print_message "$GREEN" "${EMOJI_HOURGLASS} Executando composer dump-autoload..."
composer dump-autoload

print_message "$GREEN" "${EMOJI_OK} Processo concluído com sucesso!"
exit 0