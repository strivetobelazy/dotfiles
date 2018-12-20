#!/bin/bash
#
# system information
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac
#
# function os-template(){
#   if [[ "$OSTYPE" == "linux-gnu" ]]; then
#           # ...
#   elif [[ "$OSTYPE" == "darwin"* ]]; then
#           # Mac OSX
#   elif [[ "$OSTYPE" == "cygwin" ]]; then
#           # POSIX compatibility layer and Linux environment emulation for Windows
#   elif [[ "$OSTYPE" == "msys" ]]; then
#           # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
#   elif [[ "$OSTYPE" == "win32" ]]; then
#           # I'm not sure this can happen.
  # elif [[ "$OSTYPE" == "freebsd"* ]]; then
  #         # ...
  # else
          # Unknown.
  # fi
# }

function system(){
    echo "Hello, $USER"
    echo
    echo "Today's date is `date`, this is week `date +"%V"`."
    echo
    echo "These users are currently connected:"
    w | cut -d " " -f 1 - | grep -v USER | sort -u
    echo
    echo "This is `uname -s` running on a `uname -m` processor."
    echo
    echo "Uptime information::"
    uptime
}


# print available colors and their numbers
function colours() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}m colour${i}"
        if (( $i % 5 == 0 )); then
            printf "\n"
        else
            printf "\t"
        fi
    done
}

light(){
    export VIMBG=light
    echo -n -e "\033]50;SetProfile=light\a"
}
dark(){
    export VIMBG=dark
    echo -n -e "\033]50;SetProfile=dark\a"
}

# Perform 'ls' after successful 'cd'
cdls() {
  builtin cd "$*"
  RESULT=$?
  if [ "$RESULT" -eq 0 ]
  then
    ls
  fi
}

# Create a new directory and enter it
function md() {
    mkdir -p "$@" && cd "$@"
}

function hist() {
    history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}

# find shorthand
function f() {
    find . -name "$1"
}

# get gzipped size
function gz() {
    echo "orig size    (bytes): "
    cat "$1" | wc -c
    echo "gzipped size (bytes): "
    gzip -c "$1" | wc -c
}

# All the dig info
function digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

# Escape UTF-8 characters into their 3-byte format
function escape() {
    printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
    echo # newline
}

# Decode \x{ABCD}-style Unicode escape sequences
function unidecode() {
    perl -e "binmode(STDOUT, ':utf8'); print \"$@\""
    echo # newline
}

# Extract archives - use: extract <file>
function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xjf $1 -C $2 ;;
            *.tar.gz) tar xzf $1 -C $2 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) rar x $1;;
            *.gz) gunzip $1 ;;
            *.tar) tar xf $1 -C $2;;
            *.tbz2) tar xjf $1 -C $2;;
            *.tgz) tar xzf $1 -C $2;;
            *.zip) unzip $1 -d $2;;
            *.Z) uncompress $1 ;;
            *.7z) 7z x $1 ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# doitobib(){
#      if [[ $# == 1 ]]; then
#       echo >> bib.bib;
#       curl -s "http://api.crossref.org/works/$1/transform/application/x-bibtex" >> bib.bib;
#       echo >> bib.bib;
#      else
#       echo -n "DOI = $1,  "
#       curl -s "http://api.crossref.org/works/$1/transform/application/x-bibtex" | grep $2 | sed "s/^[ \t]*//"
#      fi
# }

killport(){
  lsof -ti:$1 | xargs kill -9
}

#====== Remote sync app =======
function dsync(){
if [[ $# -eq 0 || "$#" -eq 2 ||"$#" -gt 3 ]]; then
    echo "Specify a server [server | server <source> <destination>]"
elif [[ "$#" -eq 1 ]]; then
    curr_path=`pwd`
    if [ "$curr_path" != "$HOME" ]; then
    path=`echo $curr_path | cut -d '/' -f 4-`
    rsync -arzv --prune-empty-dirs --exclude-from="$HOME/Dropbox/Dotfiles/bash/rsync_exclude.txt" -e ssh $1:~/${path}/. ${curr_path}/.
    else
      echo "Warning:Global sync on Home folder is not allowed"
    fi
else
    rsync -airzv -e ssh $1:$2 $3
fi
}

function usync(){
if [[ $# -eq 0 || "$#" -eq 2 ||"$#" -gt 3 ]]; then
    echo "Specify a server [server | server <source> <destination>]"
elif [[ "$#" -eq 1 ]]; then
  curr_path=$(pwd)
    if [ "$curr_path" != "$HOME" ]; then
      path=$(echo $curr_path | cut -d '/' -f 4-)
      rsync -arzv --exclude='.git/' --prune-empty-dirs ${curr_path}/. -e ssh $1:~/${path}/.
    else
      echo "Warning:Global sync on Home folder is not allowed"
    fi
else
    curr_path=$(pwd) # make this more universal:TODO
    curr_folder=${curr_path##*/} # current folder
    last_name=$(echo $3 | awk -F"/" '{print $(NF)}')
    last_name=${last_name//./} # empty if '.' is the last_name
    if [ -z "$last_name" ]; then
        last_name=$(echo $3 | awk -F"/" '{print $(NF-1)}')
    fi
    if [ "$curr_folder" != "$last_name" ]; then
        echo "Target file/folder is DIFFERENT(or an alias) then PWD. You want to continue?\nPress Enter or type [yes|y] to continue."
        read accept
        if [[ "$accept" == "yes" || "$accept" == "y" || "$accept" == "" ]]; then
            rsync -airzv $2 -e ssh $1:$3
        else
            return
        fi
    else
        rsync -airzv $2 -e ssh $1:$3
    fi
    # echo "$curr_folder \t ${last_name}"
fi
}

function lsync(){
    source_path=$(pwd) #make this more universal:TODO
    source_folder=${curr_path##*/} # current folder
    target_folder=$(echo $2 | awk -F"/" '{print $(NF)}')
    target_folder=${target_folder//./} # Make it empty if '.' is the target_folder
    if [ -z "$target_folder" ]; then
        target_folder=$(echo $2 | awk -F"/" '{print $(NF-1)}')
    fi
    if [ "$source_folder" != "$target_folder" ]; then
        echo "Target file/folder is DIFFERENT(or an alias) then PWD. You want to continue?\nPress Enter or type [yes|y] to continue."
        read accept
        if [[ "$accept" == "yes" || "$accept" == "y" || "$accept" == "" ]]; then
            rsync -avzh $1 $2
        else
            return
        fi
    fi
}

worksync(){
  usync $1 /Users/chand/workbench/. /Users/chand/workbench/.
}

## Command Line Interface Papers Manager (CLIP-Manager)
doitobib(){
BIB_FILE=""; BIB_INFO="";
BIB_API="http://api.crossref.org/works/"
BIB_TRANS="/transform/application/x-bibtex"
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "Processing info using a DOI"
      return
      ;;
    -d|--doi)
      shift
      if test $# -gt 0; then
        DOI=$1
      else
        echo "No DOI Specified"; exit 1
      fi
      shift
      ;;
    -i|--info)
      shift
      if test $# -gt 0; then
        BIB_INFO=$1
      fi
      shift
      ;;
    -f|--file)
      shift
      if test $# -gt 0; then
        BIB_FILE=$1
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done
# TODO make it less verbose
# Use the information gatherd above
if [[  -z  $BIB_FILE  ]];then
  if [[ ! -z $BIB_INFO ]];then
    curl -s "${BIB_API}${DOI}${BIB_TRANS}" | grep ${BIB_INFO} | sed "s/^[ \t]*//"
  else
    curl -s "${BIB_API}${DOI}${BIB_TRANS}"
  fi
elif [[  ! -z  $BIB_FILE  ]];then
    echo >> ${BIB_FILE};
    curl -s "${BIB_API}${DOI}${BIB_TRANS}" >> ${BIB_FILE}
    echo >> ${BIB_FILE};
fi
}
