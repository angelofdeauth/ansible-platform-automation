#!/usr/bin/env bash
# @File:     go-verify.sh
# @Created:  2020-03-25 17:27:04
# @Modified: 2020-03-26 19:27:50
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

set -ex

cd "$(dirname "$0")/../"

containerFunc() {
  go mod verify
  echo "[OK] Go mod verify completed!"
}

containerGen() {
  podman run --rm \
    --env IS_CONTAINER=TRUE \
    -v "$PWD":/usr/src/"$(basename "$PWD")":z \
    -w /usr/src/"$(basename "$PWD")" \
    golang:1.14 \
    ./hack/go-verify.sh "${@}"
}

conditional() {
  if command -v go >/dev/null; then
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
