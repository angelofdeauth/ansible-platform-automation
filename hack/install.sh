#!/usr/bin/env bash
# @File:     install.sh
# @Created:  2020-03-26 02:34:04
# @Modified: 2020-03-26 19:27:49
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

set -ex

cd "$(dirname "$0")/../"

install -d -m 755 "${INSTALL_PATH}" 2>&1 | tee -a "${BUILD_PATH}"/make.log
install -Z "${BUILD_PATH}/${APP}" "${INSTALL_PATH}/${APP}" 2>&1 | tee -a "${BUILD_PATH}"/make.log
echo "[OK] Binary installed successfully!" 2>&1 | tee -a "${BUILD_PATH}"/make.log
