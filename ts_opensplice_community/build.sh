#!/bin/bash

cp release.com ${PREFIX}/bin/opensplice_activate
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"

pip install tools/python/site-packages/dds-6.9*.whl
cp -r bin  docs  etc  include  jar  lib  LICENSE  README.md  release.com  tools ${PREFIX}/.





