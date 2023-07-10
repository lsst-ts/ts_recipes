#!/bin/bash

# Version string in the C library installer's file name
file_version=2019_07_16
python_file_version=2020_11_20
# The desired architecture, as descripbed in the C library installer's file name
arch=x86_64
# The version of the C library in the above file.
# To find this information:
# * Download and expand the installer.
# * cd into the new directory.
# * Run labjack_ljm_installer.run (a self-extracting archive) to expand the library code:
#   ./labjack_ljm_installer.run --keep --noexec
# Look in labjack_ljm_software for the library.
c_version=1.20.1
# Python wrapper version
python_version=1.21.0

echo "Download and unpack labjack-ljm C library labjack_ljm_software_${file_version}_${arch}.tar.gz"
# Notice the strange file extension. Unfortunately it has been uploaded like that.
curl https://cdn.docsie.io/file/workspace_u4AEu22YJT50zKF8J/doc_VDWGWsJAhd453cYSI/boo_9BFzMKFachlhscG9Z/file_6ct0vbMEidvixvYCA/labjack_ljm_software_${file_version}_${arch}tar.gz -o labjack_ljm_software_${file_version}_${arch}.tar.gz
curl -O https://cdn.docsie.io/file/workspace_u4AEu22YJT50zKF8J/doc_VDWGWsJAhd453cYSI/boo_KXghxr3Yqvg6QlfuD/file_5cXspLnLTSUkz2oPl/python_ljm_${python_file_version}.zip

# labjack_ljm_installer.run creates a directory labjack_ljm_software
# which includes setup.sh, the script that installs the library.
# It hard-codes the destination, so run sed to patch it.
tar -xzf labjack_ljm_software_${file_version}_${arch}.tar.gz
unzip python_ljm_${python_file_version}.zip

cd labjack_ljm_software_${file_version}_${arch}
./labjack_ljm_installer.run --keep --noexec

echo "Install labjack-ljm C library ${c_version}"
cd labjack_ljm_software
# The installer file has /usr/local hard-coded; patch it:
sed "s|=/usr/local|=${PREFIX}|" setup.sh >temp.sh
# Stop before doing the following steps:
# * ldconfig, because it tries to update system ldconfig, which is the wrong one
# * Installing rules: setup.sh puts them in /etc; where is that in conda images?
#   I hope we don't need them.
# * Installing Kipling: we don't need it. Note that there is also
#   an undocumented command-line argument for this, in case we figure out
#   how to update the right ldconfig and install rules in the correct location.
sed "s|install_ljm_constants$|install_ljm_constants\n\n# Quit early\nsuccess|" temp.sh >patchedsetup.sh
rm temp.sh
# Show the diff; `|| true` makes this command return 0, so the script continues.
echo "Diff between patched and unpatched install script:"
diff patchedsetup.sh setup.sh || true
bash patchedsetup.sh ${c_version}

ls -la ${PREFIX}/

# This command is based on the conda's click example
echo "Install labjack-ljm Python wrapper ${python_version}"

cd ../../Python_LJM_${python_file_version}/

cat >> labjack/ljm/ljm.py <<EOL


# Vera Rubin Observatory patch to make the conda package work.
import os
import pathlib

CONSTANTS_FILE_RELATIVE_PATH = pathlib.Path("LabJack/LJM/ljm_constants.json")
CONSTANTS_FILE_DEFAULT_PATH = (
    pathlib.Path("/usr/local/share") / CONSTANTS_FILE_RELATIVE_PATH
)
CONDA_PREFIX = os.environ.get("CONDA_PREFIX")
if not os.path.exists(CONSTANTS_FILE_DEFAULT_PATH) and CONDA_PREFIX is not None:
    # Try to load the file from the conda package. If this fails then it will
    # manifest itself when the library is attempted to be used.
    CONSTANTS_FILE_CONDA_PATH = str(
        CONDA_PREFIX / pathlib.Path("share") / CONSTANTS_FILE_RELATIVE_PATH
    )
    writeLibraryConfigStringS(constants.CONSTANTS_FILE, CONSTANTS_FILE_CONDA_PATH)

EOL

${PYTHON} -m pip install . -vv

ls -la ${PREFIX}/

echo "done"
