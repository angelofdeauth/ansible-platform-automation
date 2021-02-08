#!/usr/bin/env bash
# @File:     go-sec.sh
# @Created:  2020-03-25 16:21:37
# @Modified: 2020-03-27 17:42:22
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

set -ex

cd "$(dirname "$0")/../"

containerFunc() {
  if ! command -v gosec >/dev/null; then
    cd /tmp
    go get github.com/securego/gosec/cmd/gosec
    cd -
  fi
  gosec \
    -severity high \
    -confidence high \
    ./... "${@}"
  echo "[OK] Go security check completed!"
}

containerGen() {
  podman run --rm \
    --env IS_CONTAINER=TRUE \
    -v "$PWD":/usr/src/"$(basename "$PWD")":z \
    -w /usr/src/"$(basename "$PWD")" \
    golang:1.14 \
    ./hack/go-sec.sh "${@}"
}

conditional() {
  if command -v gosec >/dev/null; then
    containerFunc "${@}"
  else
    containerGen "${@}"
  fi
}

# run gosec from inside the container
if [ "$RELEASE" = "true" ]; then
  conditional "${@}" 2>&1 | tee -a "${BUILD_PATH}"/make.log
else
  conditional "${@}" 2>&1 | tee -a "${BUILD_PATH}"/make.log
fi
