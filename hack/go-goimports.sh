#!/usr/bin/env bash
# @File:     go-goimports.sh
# @Created:  2020-03-25 15:05:46
# @Modified: 2020-03-27 17:41:08
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

set -ex

cd "$(dirname "$0")/../"

containerFunc() {
  if ! command -v goimports >/dev/null; then
    cd /tmp
    go get golang.org/x/tools/cmd/goimports
    cd -
  fi
  for TARGET in "${@}"; do
    find "${TARGET}" \
      -name '*.go' \
      ! -path '*/vendor/*' \
      ! -path '*/.build/*' \
      -exec goimports \
      -w {} \+
  done
  echo "[OK] Goimports completed successfully!" 
}

containerGen() {
  podman run --rm \
    --env IS_CONTAINER=TRUE \
    -v "$PWD":/usr/src/"$(basename "$PWD")":z \
    -w /usr/src/"$(basename "$PWD")" \
    golang:1.14 \
    ./hack/go-goimports.sh "${@}"
}

conditional() {
  if command -v goimports >/dev/null; then
    containerFunc "${@}"
  else
    containerGen "${@}"
  fi
}

# run goimports from inside the container
if [ "$RELEASE" = "true" ]; then
  conditional "${@}" 2>&1 | tee -a "${BUILD_PATH}"/make.log
else
  conditional "${@}" 2>&1 | tee -a "${BUILD_PATH}"/make.log
fi
