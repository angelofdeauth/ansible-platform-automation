#!/usr/bin/env bash
# @File:     build.sh
# @Created:  2020-03-25 14:57:39
# @Modified: 2020-03-29 01:39:08
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

set -ex

cd "$(dirname "$0")/../"

# shellcheck disable=SC2068
version() { IFS="."; printf "%03d%03d%03d\\n" $@; unset IFS;}

if [ "$(version "${CURR_GO_VERSION#go}")" -lt "$(version "${MINIMUM_GO_VERSION}")" ]; then
  echo "Go version should be greater or equal to: ${MINIMUM_GO_VERSION}"
  exit 1
fi

GOFLAGS="${GOFLAGS:--mod=vendor}"
LDFLAGS="${LDFLAGS} -X 'pkg/app.VERSION=${VERSION}' -X 'pkg/app.TIME=$(date -u)' -X 'pkg/app.COMMIT=${COMMIT}' -X 'pkg/app.APP=${APP}'"
TAGS="${VERSION}"

containerFunc() {
  GOARCH="${ARCH}" GOOS="${OS}" \
    go build \
    -a \
    -v \
    -x \
    -trimpath \
    "${GOFLAGS}" \
    -o="${BUILD_PATH}"/"${APP}" \
    -ldflags "${LDFLAGS}" \
    -tags "${TAGS}"
  echo "[OK] Binary created successfully!"
}

containerGen() {
  podman run --rm \
    --env IS_CONTAINER=TRUE \
    -v "$PWD":/usr/src/"$(basename "$PWD")":z \
    -w /usr/src/"$(basename "$PWD")" \
    golang:1.14 \
    ./hack/build.sh
}

build() {
  if command -v go >/dev/null; then
    containerFunc
  else
    containerGen
  fi
}

# Build binary
if [ "${RELEASE}" = "true" ]; then
  LDFLAGS="${LDFLAGS} -s -w"
  TAGS="${TAGS} release"
  build 2>&1 | tee -a "${BUILD_PATH}"/make.log
  mv "${BUILD_PATH}"/make.log "${LOG_PATH}"/make.log
else
  build 2>&1 | tee -a "${BUILD_PATH}"/make.log
fi
