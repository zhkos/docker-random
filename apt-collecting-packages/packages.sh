#!/bin/bash

fetch-packages() {
  apt-get download $(apt-cache depends --recurse \
    --no-recommends --no-suggests --no-conflicts --no-breaks \
    --no-replaces --no-enhances "$PCKG" |
    grep "^\w" | grep -v "$(dpkg --print-architecture)" | sort -u) >/dev/null 2>&1 &&
    echo "$LOG_SUCCESS [ $PCKG ] Downloaded"
}

scan-pack() {
  dpkg-scanpackages -m -t deb "$PATH_TO_PCKGS" | gzip -9c >"$PATH_TO_PCKGS"Packages.gz
  echo "$LOG_SUCCESS Output Packages.gz created"
}

update-cache() {
  apt-get update >/dev/null 2>&1 &&
    echo "$LOG_SUCCESS Packages cache updated"
}

filter-packages() {
  for PCKG in $TARGET_PACKAGES; do
    #echo "$LOG_INFO [ $PCKG ] : Try to find package"
    [[ "$(apt-cache policy "$PCKG")" == *"$PCKG"* ]]
    pckg_exist="$?"
    [[ "$(apt-cache policy "$PCKG" | grep -Eo 'Candidate:.*')" != "Candidate: (none)" ]]
    pckg_none="$?"
    if [[ "$pckg_exist" == 0 && "$pckg_none" == 0 ]]; then
      echo "$LOG_SUCCESS [ $PCKG ] : Package found"
      PCKGNAME_DIR_NAME="${PCKGNAME_DIR_NAME}_$PCKG"
      PCKG_FILTERED_LIST="${PCKG_FILTERED_LIST} $PCKG"
      ((i += 1))
    else
      echo "$LOG_FAILURE [ $PCKG ] : Package not found"
      continue
    fi
  done
}

creating-dirs() {
  DIRNAME="${i}_debs:${PCKGNAME_DIR_NAME}"
  PATH_TO_PCKGS="$PACKSDIR/$DIRNAME/"
  mkdir -p "$DIRNAME"
  mv "$PACKSDIR"/*.deb "$DIRNAME"
}

function main {
  LOG_INFO="[I]:"
  LOG_SUCCESS="[S]:"
  LOG_FAILURE="[F]:"

  echo "$LOG_INFO Input packages: $TARGET_PACKAGES"
  update-cache
  filter-packages
  echo "$LOG_SUCCESS [ $PCKG_FILTERED_LIST ] Found packages"

  for PCKG in $PCKG_FILTERED_LIST; do
    #echo "$LOG_INFO [ $PCKG ] Download package"
    fetch-packages
  done

  creating-dirs
  scan-pack
}

main
