#!/usr/bin/env bash
# @File:     clean.sh
# @Created:  2020-03-26 02:35:47
# @Modified: 2020-03-26 19:52:09
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

set -ex

cd "$(dirname "$0")/../"

if [ -e "${BUILD_PATH}" ]; then rm -rf "${BUILD_PATH}"; fi
if [ -f "${LOG_PATH}/make.log" ] && [ "${RELEASE}" = "true" ]; then :>"${LOG_PATH}"/make.log; fi
echo "[OK] Build ${APP}-${VERSION}-${FILE_ARCH} cleaned!"
