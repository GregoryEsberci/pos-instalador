#!/bin/bash
set -e

function notifies_current_process() {
  echo -e "
####################################
${1}
####################################
"
}

set_ssh_key_git_hub() {
  ERRORS_CURL_PATCH="./output_curl"
  mkdir -p ${ERRORS_CURL_PATCH}
  read -p 'Usário github: ' LOGIN
  if [[ -z LOGIN ]]
  RESPONSE_CODE=$(curl -u $LOGIN --data '{"title":"test-key","key":"ssh-rDDsa AAA..."}' -o ./output_curl/teste.txt -s -w "%{http_code}"  https://api.github.com/user/keys)

  if (( $RESPONSE_CODE != 200 )); then
    echo "Erro ao adicionar chave ssh - HTTP ${RESPONSE_CODE}"
    echo "Resposta completa esta salva em "
    echo $TESTE
  fi
  # curl -u "username:password" --data '{"title":"test-key","key":"ssh-rsa AAA..."}' https://api.github.com/user/keys
}


set_ssh_key_git_hub