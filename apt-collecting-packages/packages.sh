#!/bin/bash

fetch-packages() {
  apt-get download $(apt-cache depends --recurse \
    --no-recommends --no-suggests --no-conflicts --no-breaks \
    --no-replaces --no-enhances "$PCKG" |
    grep "^\w" | grep -v "$(dpkg --print-architecture)" | sort -u) >/dev/null &&
    echo "$LOG_SUCCESS Packages downloaded"
}

scan-pack() {
  dpkg-scanpackages -m -t deb "$PATH_TO_PCKGS" | gzip -9c >"$PATH_TO_PCKGS"Packages.gz 2>/dev/null &&
    dpkg-scanpackages -m -t deb "$PATH_TO_PCKGS" >"$PATH_TO_PCKGS"Release 2>/dev/null
  echo "$LOG_SUCCESS Output Packages.gz and Release files created"
}

update-cache() {
  apt-get update >/dev/null 2>&1 &&
    echo "$LOG_SUCCESS Packages cache updated"
}

filter-packages() {
  for PCKG in $TARGET_PACKAGES; do
    echo "$LOG_INFO Try to find package: $PCKG"
    [[ "$(apt-cache policy "$PCKG")" == *"$PCKG"* ]]
    pckg_exist="$?"
    [[ "$(apt-cache policy "$PCKG" | grep -Eo 'Candidate:.*')" != "Candidate: (none)" ]]
    pckg_none="$?"
    if [[ "$pckg_exist" == 0 && "$pckg_none" == 0 ]]; then
      echo "$LOG_SUCCESS Package $PCKG found"
      PCKGNAME_DIR_NAME="${PCKGNAME_DIR_NAME}_$PCKG"
      PCKG_FILTERED_LIST="${PCKG_FILTERED_LIST} $PCKG"
      ((i += 1))
    else
      echo "$LOG_FAILURE Package $PCKG not found"
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
  LOG_INFO="[Info]:"
  LOG_SUCCESS="[Success]:"
  LOG_FAILURE="[Failure]:"

  echo "$LOG_INFO Input packages: $TARGET_PACKAGES"
  update-cache
  filter-packages
  echo "$LOG_SUCCESS Found packages: $PCKG_FILTERED_LIST"

  for PCKG in $PCKG_FILTERED_LIST; do
    echo "$LOG_INFO Download packages for: $PCKG"
    fetch-packages
  done

  creating-dirs
  scan-pack
}

main
