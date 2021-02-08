#!/usr/bin/env bash
# @File:     go-lint.sh
# @Created:  2020-03-25 16:21:26
# @Modified: 2020-03-27 17:42:26
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

set -ex

cd "$(dirname "$0")/../"

containerFunc() {
  if ! command -v golint >/dev/null; then
    cd /tmp
    go get -u golang.org/x/lint/golint
    cd -
  fi
  for TARGET in "${@}"; do
    find "${TARGET}" \
      -name '*.go' \
      ! -path '*/vendor/*' \
      ! -path '*/.build/*' \
      -exec golint \
        -set_exit_status {} \+
  done
  echo "[OK] Golint completed successfully!" 
}

containerGen() {
  podman run --rm \
    --env IS_CONTAINER=TRUE \
    -v "$PWD":/usr/src/"$(basename "$PWD")":z \
    -w /usr/src/"$(basename "$PWD")" \
    golang:1.14 \
    ./hack/go-lint.sh "${@}"
}

conditional() {
  if command -v golint >/dev/null; then
    containerFunc "${@}"
  else
    containerGen "${@}"
  fi
}

# run golint from inside the container
if [ "$RELEASE" = "true" ]; then
  conditional "${@}" 2>&1 | tee -a "${BUILD_PATH}"/make.log
else
  conditional "${@}" 2>&1 | tee -a "${BUILD_PATH}"/make.log
fi
