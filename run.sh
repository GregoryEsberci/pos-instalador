#!/bin/bash
set -e

# https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc
# TODO: Adicionar limite maxiomo no /proc/sys/fs/inotify/max_user_watches
# TODO: Criar alias para o robo3t-snap (não neste arquivo)

NVM_LTS='v0.35.2'
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

PACKAGES_APT=(
  'apt-transport-https'
  'libreoffice'
  'qbittorrent'
  'git'
  'htop'
  'vlc'
  'gnome-tweaks'
  'gimp'
  'steam'
  'traceroute'
  'net-tools'
  'samba'
  'curl'
  'docker-compose'
  'dconf-editor'
  'virtualbox'
  'p7zip-full'
)

PACKAGES_SNAP=(
  '--classic code'
  'robo3t-snap'
)

DOWNLOAD_DEB_FILES=(
  'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
)

mkdir -p /tmp/instalar ~/.themes
cd /tmp/instalar


function notifies_current_process() {
  echo -e "
####################################
${1}
####################################
"
}

echo '"sudo passwd", crie uma senha para o usuário root'
sudo passwd

notifies_current_process 'Aplicando configurações personalizadas'

# TODO: validar se os temas existem, se exestirem so dar um set, senao baixar eles antes

# Não encerra o script casso ocorram erros neste trecho
set +e

# Tempo de bloqueio da tela 30 minutos (1800 segundos)
gsettings set org.gnome.desktop.session idle-delay 1800
# Tema GTK
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
# Icones
gsettings set org.gnome.desktop.interface icon-theme 'ubuntu-mono-dark'
# Cursor
gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-Black'
# Desabilita animações
gsettings set org.gnome.desktop.interface enable-animations false
# Mostrar porcentagem da bateria na barra superior
gsettings set org.gnome.desktop.interface show-battery-percentage true
# Não desabilita touthtouchpad enquanto digita
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing false
# Emulação de clique do mouse
gsettings set  org.gnome.desktop.peripherals.touchpad click-method 'fingers'
# Amplificador, permite aumetar o voluma acima de 100%
gsettings set com.ubuntu.sound allow-amplified-volume true
# Desabilitar som do gnome-terminal
DEFAULT_PROFILE_GNOME_TERMINAL=$(gsettings get org.gnome.Terminal.ProfilesList default)
DEFAULT_PROFILE_GNOME_TERMINAL=${profile:1:-1} # Remover aspas simples iniciais e finais
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${DEFAULT_PROFILE_GNOME_TERMINAL}/ audible-bell false

# Plano de fundo 
# Não mostra icones
gsettings set org.gnome.desktop.background show-desktop-icons false
# Remove imagem
gsettings set org.gnome.desktop.background picture-uri none
# Define a cor como solida
gsettings set org.gnome.desktop.background color-shading-type solid
# Seta a cor 
gsettings set org.gnome.desktop.background primary-color '#111111'

# Tela de bloqueio
gsettings set org.gnome.desktop.screensaver show-desktop-icons false
# Remove imagem
gsettings set org.gnome.desktop.screensaver picture-uri none
# Define a cor como solida
gsettings set org.gnome.desktop.screensaver color-shading-type solid
# Seta a cor
gsettings set org.gnome.desktop.screensaver primary-color '#111111'

# Mostra a data junto com a hora
gsettings set org.gnome.desktop.interface clock-show-date true
# Deixa apenas o nautilus na barra lateral
gsettings set org.gnome.shell favorite-apps [\'org.gnome.Nautilus.desktop\']

set -e

# Instala pacotes apt
notifies_current_process 'Instalando pacotes apt'
sudo apt install -y ${PACKAGES_APT[@]}

# Instala pacotes snap
notifies_current_process 'Instalando pacotes snap'
sudo snap install ${PACKAGES_SNAP[@]}

# Baixa e instala pacotes .deb
notifies_current_process 'Baixando e instalando pacotes .deb'
wget -nv -c ${DOWNLOAD_DEB_FILES[@]}
sudo apt install ./*.deb

# Gerenciar o Docker como um usuário que não é root
notifies_current_process 'Alterando permissões do usuário docker'
getent group docker || groupadd docker
sudo usermod -aG docker ${USER}

# NVM
notifies_current_process 'Instalando e configurando nvm'
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_LTS}/install.sh | bash
. $HOME/.nvm/nvm.sh --sorce-only
nvm install --lts
nvm install 9

# Atualiza sistema
notifies_current_process 'Atualizando o sistema'
sudo apt dist-upgrade

# Remover bibliotecas obsoletas e arquivos de pacotes órfãos
notifies_current_process 'Removendo pacotes e pastas descessessarias'
sudo apt autoclean -y
sudo apt autoremove --purge -y


# TODO: Pedir usuario do gitHub com descrição similar a "precione enter se não possue usuario"
# Validar se a chave foi adicionada com sucesso, se não foi peça o usuario é a senha novamente 
# (usuario preenchido com o valor anterior, se possivel) 
# Gera chave SSH é adiciona no GitHub
notifies_current_process 'Gerando chave SSH'
ssh-keygen -t rsa -b 4096 -C
ssh-add -L
notifies_current_process 'Adicionando chave SSH no gitHub'

# Inacabado
set_ssh_key_git_hub() {
  ERRORS_CURL_PATCH="./output_curl"
  mkdir -p ${ERRORS_CURL_PATCH}
  # TODO: Pedir usuário e senha do gitHub
  RESPONSE_CODE=$(curl -u "usuario:senha" --data '{"title":"test-key","key":"ssh-rDDsa AAA..."}' -o ./output_curl/teste.txt -s -w "%{http_code}" https://api.github.com/user/keys)

  if (( $RESPONSE_CODE != 200 )); then
    echo "Erro ao adicionar chave ssh - HTTP ${RESPONSE_CODE}"
    echo "Resposta completa esta salva em "
    echo $TESTE
  fi
  # curl -u "username:password" --data '{"title":"test-key","key":"ssh-rsa AAA..."}' https://api.github.com/user/keys
}

# set_ssh_key_git_hub

# Configurando usuario git
notifies_current_process 'Configurando usuario git'
read -p 'Email: ' $GIT_EMAIL
git config --global user.email $GIT_EMAIL

read -p 'Nome: ' $GIT_NAME
git config --global user.name $GIT_NAME

read -p 'Chave de assinatura: ' $GIT_SIGNINGKEY
git config --global user.signingkey $GIT_SIGNINGKEY

notifies_current_process 'Instalação finalizada com sucesso'
echo 'Para concluir as instalações é necessario reinicias o computar'
read -n 1 -s -r -p 'Precione qualquer tecla para continuar, ou "Ctrl + C" para cancelar'

sudo reboot