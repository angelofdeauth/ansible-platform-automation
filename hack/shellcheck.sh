#!/usr/bin/env bash
# @File:     shellcheck.sh
# @Created:  2020-03-25 16:22:10
# @Modified: 2020-03-26 21:47:00
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

set -ex

cd "$(dirname "$0")/../"

containerFunc() {
  TOP_DIR="${1:-.}"
    find "${TOP_DIR}" \
      -path "${TOP_DIR}/vendor" \
      -prune -o -type f -name '*.sh' \
      -exec shellcheck --format=tty {} \+
  echo "[OK] Shellcheck completed!"
}

containerGen() {
  podman run --rm \
    --entrypoint sh \
    --env IS_CONTAINER=TRUE \
    -v "$PWD":/workdir:ro,z \
    -w /workdir \
    koalaman/shellcheck-alpine:v0.7.0 \
    /workdir/hack/shellcheck.sh "${@}"
}

conditional() {
  if command -v shellcheck >/dev/null; then
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
