#!/usr/bin/env bash
# @File:     go-generate.sh
# @Created:  2020-03-25 16:21:14
# @Modified: 2020-03-26 19:27:57
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

set -ex

cd "$(dirname "$0")/../"

containerFunc() {
  rm -rf "${BOX_BLOBFILE}"
  go generate ./... "${@}"
  echo "[OK] Go generate completed successfully!" 
}

containerGen() {
  podman run --rm \
    --env IS_CONTAINER=TRUE \
    -v "$PWD":/usr/src/"$(basename "$PWD")":z \
    -w /usr/src/"$(basename "$PWD")" \
    golang:1.14 \
    ./hack/go-generate.sh "${@}"
}

conditional() {
  if command -v go >/dev/null; then
    containerFunc "${@}"
  else
    containerGen "${@}"
  fi
}

# run go generate from inside the container
if [ "$RELEASE" = "true" ]; then
  conditional "${@}" 2>&1 | tee -a "${BUILD_PATH}"/make.log
else
  conditional "${@}" 2>&1 | tee -a "${BUILD_PATH}"/make.log
fi
