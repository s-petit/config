# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="powerline"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export TERM="xterm-256color"
export DEV_HOME="/home/spetit/dev"
export MIRAKL_HOME="$DEV_HOME/IdeaProjects/marketplace-platform"
export JAVA_HOME="$DEV_HOME/tools/jdk1.8.0_73"
export IDEA_HOME="$DEV_HOME/tools/idea-IU-143.2287.1"
export M2_HOME="$DEV_HOME/tools/apache-maven-3.3.9"
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=256m"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$JAVA_HOME/bin:$IDEA_HOME/bin:$M2_HOME/bin:"

cd $MIRAKL_HOME/

# b : build, r: run, t: test -- a : all, g: grails, s: services, w: web, e : edit
alias _ba='cd $MIRAKL_HOME; mvn license:format; mvn clean install -DskipTests=true -PskipTests'
alias _rg='cd $MIRAKL_HOME/mirakl-mp; grails-debug -reloading run-app'
alias bashrc='sudo mousepad /etc/bash.bashrc'
alias _rbb='cd $MIRAKL_HOME/mirakl-tests-blackbox/tomcat-starter; mvn clean verify -Pinit_db,tomcat_start'
alias idea='cd $IDEA_HOME/bin; nohup ./idea.sh'
alias _dump-install='/home/spetit/scripts/install_dump.sh $1 > /home/spetit/scripts/logs/last_dump.log'
alias _dump-dl-install='/home/spetit/scripts/dl_and_install_dump.sh $1 $2 > /home/spetit/scripts/logs/last_dump.log'
alias _pom-resolve-conflict='/home/spetit/scripts/pom_conflict_resolver.sh $1'
#alias _dump-download='/home/spetit/scripts/dl_dump.sh $1'
alias _repo-logs='ssh developer@log.mirakl;'
alias _repo-dumps='ssh developer@mirakl-dump.mirakl.net;'
alias _dump_show='ssh developer@mirakl-dump.mirakl.net ls -l;'
alias _postgres_start='sudo /etc/init.d/postgresql start;'
alias _postgres_stop='sudo /etc/init.d/postgresql stop;'
alias zshconfig='mousepad ~/.zshrc'
alias j='fasd_cd -d'

#powerline custom settings
POWERLINE_RIGHT_B="none"
POWERLINE_DISABLE_RPROMPT="true"
POWERLINE_HIDE_HOST_NAME="true"


# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Annoyed of the auto-correct functionality?
unsetopt correct_all

setopt INTERACTIVE_COMMENTS # allow inline comments

autoload -U zmv

#fasd
if hash fasd 2>/dev/null; then
    eval "$(fasd --init auto)"
else
    echo "You should install fasd! https://github.com/clvv/fasd"
fi

#peco
function peco-select-history() {
    local tac
    if which tac > /dev/null; then
	tac="tac"
    else
	tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
		    eval $tac | \
		    peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}

if hash peco 2>/dev/null; then
    zle -N peco-select-history
    bindkey '^r' peco-select-history
else
    echo "You should install peco! https://github.com/peco/peco"
fi

eval "$(fasd --init auto)"
