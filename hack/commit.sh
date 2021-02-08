#!/usr/bin/env bash
# @File:     commit.sh
# @Created:  2020-03-26 20:27:09
# @Modified: 2020-04-01 14:01:38
# @OA:       Antonio Escalera
# @CA:       Antonio Escalera
# @Mail:     aj@angelofdeauth.host
# @Copy:     Copyright © 2019 Antonio Escalera <aj@angelofdeauth.host>

set  -ex

cd "$(dirname "$0")/../"

conditionalAddAll() {
  git diff
  read -r -p "Add all files (y/n)?" choice
  case "$choice" in 
    y|Y ) echo "[OK] Adding all files..." && git add . && gitcomm && git push;;
    n|N ) echo "[ERROR] Exiting..."; exit 2;;
    * ) echo "[ERROR] Invalid, exiting..."; exit 3;;
  esac
}

containerFunc() {
  if ! command -v gitcomm >/dev/null; then
    cd /tmp
    go get -u -d github.com/angelofdeauth/gitcomm/cmd
    go build -o "${GOPATH}"/bin/gitcomm ./cmd/...
    cd -
  fi
  
  git status

  # test if there are changed tracked files which are cached, 1 is cached changes and 0 is none.
  if git diff --cached --quiet ; then
    
    # test if there are changed tracked files which are not cached, 1 is uncached changes and 0 is none.
    if git diff-index "$(git write-tree)" --quiet -- ; then

      # test if there are any uncommitted changes between the current filesystem and HEAD (catchall for new files).
      if [ -n "$(git status -s)" ]; then
        echo "No changes detected either cached, new, or staged."
      else
        conditionalAddAll
      fi
    else
      conditionalAddAll
    fi
  else
    git diff --cached
    gitcomm
    git push
  fi 
  echo "[OK] Commit completed!"
}

containerGen() {
  podman run --rm \
    --env IS_CONTAINER=TRUE \
    -v "$PWD":/usr/src/"$(basename "$PWD")":z \
    -w /usr/src/"$(basename "$PWD")" \
    golang:1.14 \
    ./hack/commit.sh
}

conditional() {
  if command -v gitcomm >/dev/null; then
    containerFunc
  else
    containerGen
  fi
}

conditional
