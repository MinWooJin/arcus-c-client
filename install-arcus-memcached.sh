#!/bin/sh
set -e
CWD=$(pwd)

TARGET_SERVER_BR="master"
if [ ! -z "$1" ]; then
  TARGET_SERVER_BR=$1
fi

checkBranch() {
  git remote update
  UPSTREAM=${1:-'@{u}'}
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse "$UPSTREAM")
  BASE=$(git merge-base @ "$UPSTREAM")

  if [ $LOCAL = $REMOTE ]; then
    echo "UPTODATE"
  elif [ $LOCAL = $BASE ]; then
    echo "NEEDTOPULL"
  elif [ $REMOTE = $BASE ]; then
    echo "NEEDTOPUSH"
  else
    echo "DIVERGED"
  fi
}

# check to see if arcus-memcached folder is empty
if [ ! -x "$HOME/arcus-memcached/memcached" ]
then
  echo "No arcus-memcached installation! running clone and build..."
  git clone git://github.com/naver/arcus-memcached.git $HOME/arcus-memcached
  cd $HOME/arcus-memcached
  git checkout $TARGET_SERVER_BR
  git pull
  ./config/autorun.sh
  ./configure
  make

else  # cache exist
  echo "Using cached arcus-memcached installation"
  cd $HOME/arcus-memcached
  echo "Checking update of ARCUS project..."
  git checkout $TARGET_SERVER_BR
  git pull
  ./configure
  make
fi
cd $CWD
