#!/usr/bin/env bash
set -eu

{
  git clone https://github.com/creationix/nvm.git /opt/nvm
  mkdir /usr/local/nvm
  export NVM_DIR=/usr/local/nvm
  . /opt/nvm/nvm.sh
  LATEST="v16.14.2"
  nvm install $LATEST
  nvm alias default $LATEST
  nvm use $LATEST
  npm version | xargs
}
