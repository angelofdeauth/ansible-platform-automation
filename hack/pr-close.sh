#!/usr/bin/env bash
# @File:     pr-close.sh
# @Created:  2020-03-27 01:04:32
# @Modified: 2020-04-02 01:14:51
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

set -ex

cd "$(dirname "$0")/../"

mergefn() {
  git fetch origin
  git checkout -b "${BRANCH}" origin/"${BRANCH}"
  git merge master
  git checkout master
  git merge --no-ff "${BRANCH}"
  git push origin master
  git branch -d "${BRANCH}"
  git push origin --delete "${BRANCH}"
}

if mergefn; then
  echo "[OK] PR for branch ${BRANCH} merged successfully!"
else
  echo "[ERROR] PR for branch ${BRANCH} merge failed!"
fi
