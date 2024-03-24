#!/bin/bash

set -e
set -o pipefail

# this function should be called with some arguments
# The first argument is which esp_idf version to use

ESP_VER=${1}
MICROPYTHON_VER=$(curl --silent https://api.github.com/repos/micropython/micropython/releases | jq -r '.[0].tag_name')

HOME_DIR=$(pwd)
ESP_IDF_REPO="https://github.com/espressif/esp-idf.git"
ESP_IDF="${HOME_DIR}/esp-idf"
MICROPYTHON_REPO="https://github.com/micropython/micropython.git"
MICROPYTHON="${HOME_DIR}/micropython"

if which nproc > /dev/null; then
    MAKEOPTS="-j$(nproc)"
else
    MAKEOPTS="-j$(sysctl -n hw.ncpu)"
fi

# Ensure known OPEN_MAX (NO_FILES) limit.
ulimit -n 1024

function clone_or_update() {
  repo=${1}
  dir=${2}
  if [ -d ${dir} ] ; then
    cd ${dir}
    git checkout main > /dev/null 2>&1 || git checkout master > /dev/null 2>&1
    git pull --quiet
  else
    cd $(dirname ${dir})
    git clone --quiet --filter=tree:0 ${repo}
  fi
}

function install_idf() {
  # Setup the idf repository
  clone_or_update ${ESP_IDF_REPO} ${ESP_IDF}
  cd ${ESP_IDF}
  git checkout ${ESP_VER} > /dev/null 2>&1
  echo "Getting submodules"
  git submodule update --init --recursive --filter=tree:0 --quiet
  echo "Installing esp-idf ${ESP_VER}"
  ./install.sh
}

function setup_micropython() {
  # Setup the micropython repository
  clone_or_update ${MICROPYTHON_REPO} ${MICROPYTHON}
  cd ${MICROPYTHON}
  git checkout ${MICROPYTHON_VER} > /dev/null 2>&1
}

function validate_idf_tag() {
  # check that the argument is one of the valid versions
  for ver in "v5.0.4" "v5.1.3" "v5.2"; do
    if [ "${ESP_VER}" == "${ver}" ] ; then
      return 0
    fi
  done
  echo "${ESP_VER} is not a valid version"
  exit -1
}

function build_micropython() {
  # Building micropython
  #
  source ${ESP_IDF}/export.sh > /dev/null 2>&1

  if [ -d build-ESP32_GENERIC ] ; then
    make ${MAKEOPTS} clean
    rm -rf build-ESP32_GENERIC
  fi

  echo "Building micropython ${MICROPYTHON_VER}"

  cd ${MICROPYTHON}/mpy-cross

  echo "Building mpy-cross"
  make ${MAKEOPTS}

  cd ${MICROPYTHON}/ports/esp32

  echo "Building submodules"
  make ${MAKEOPTS} BOARD=ESP32_GENERIC submodules
  echo "Building micropython"
  make ${MAKEOPTS}
}

function rename_micropython () {
  cp ${MICROPYTHON}/ports/esp32/build-ESP32_GENERIC/micropython.bin \
    ${HOME_DIR}/micropython-${MICROPYTHON_VER}-${ESP_VER}.bin
}

function write_out_vars() {
  echo "" > ${HOME_DIR}/vars
  echo "version=${MICROPYTHON_VER}-${ESP_VER}" >> ${HOME_DIR}/vars
}

validate_idf_tag

install_idf

setup_micropython

build_micropython

rename_micropython

write_out_vars
