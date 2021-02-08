#!/usr/bin/env bash
# @File:     release.sh
# @Created:  2020-03-25 16:21:59
# @Modified: 2020-04-02 00:25:47
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

# Prepare for a release.  Usage:
#
#   $ hack/release.sh

set -ex

cd "$(dirname "$0")/../"

containerFunc() {
  if ! command -v gitcomm >/dev/null; then
    cd /tmp
    go get -u -d github.com/angelofdeauth/gitcomm/cmd
    go build -o "${GOPATH}"/bin/gitcomm ./cmd/...
    cd -
  fi
  
  for GOOS in darwin linux windows; do
    GOARCH=amd64
    GOOS="${GOOS}" GOARCH="${GOARCH}" make build
    RELEASE_PATH="${BUILD_DIR}/${SEMVER}/${GOOS}_${GOARCH}"
    sha512sum "${RELEASE_PATH}"/* >"${RELEASE_PATH}"/release.sha512
    gpg --output "${RELEASE_PATH}"/release.sha512.sig --detach-sig "${RELEASE_PATH}"/release.sha512
  done
  
  gitcomm --tag
  
  echo "[OK] Release build completed!"
}

containerGen() {
  podman run --rm \
    --env IS_CONTAINER=TRUE \
    -v "$PWD":/usr/src/"$(basename "$PWD")":z \
    -w /usr/src/"$(basename "$PWD")" \
    golang:1.14 \
    ./hack/release.sh
}

conditional() {
  if command -v gitcomm >/dev/null; then
    containerFunc
  else
    containerGen
  fi
}

conditional
