#!/usr/bin/env bash
# @File:     yaml-lint.sh
# @Created:  2020-03-25 16:24:14
# @Modified: 2020-03-26 19:27:47
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

set -ex

cd "$(dirname "$0")/../"

containerFunc() {
  yamllint .
  echo "[OK] YAML lint completed!"
}

containerGen() {
  podman run --rm \
    --entrypoint sh \
    --env IS_CONTAINER=TRUE \
    -v "$PWD":/workdir:z \
    -w /workdir \
    quay.io/coreos/yamllint \
    ./hack/yaml-lint.sh "${@}"
}

conditional() {
  if command -v yamllint >/dev/null; then
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
