# cd <dir>
alias cd..='cd ../'
alias cd-='cd -'
alias cd~='cd ~/'
alias ..='cd ..'

# visual studio code
alias code.='code .'

# Busca de comandos
alias hs='history | grep'

# IP
alias myip='
echo "IP local: "`ip route get 8.8.4.4 | head -1 | awk "{print \\$7}"`
echo "IP remoto: "`curl -s ifconfig.me`'

# Geral
alias window-pid="xprop | awk '/PID/ {print \$3}'"
alias window-kill="kill -9 \`window-pid\`"
alias test-microphone="arecord | aplay"

# Git
alias branch-rm="git branch --merged | grep -v \* | xargs git branch -D"
