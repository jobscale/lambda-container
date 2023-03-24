#!/usr/bin/env bash
set -eu

. /etc/profile.d/nvm.sh
npx aws-lambda-ric $@
