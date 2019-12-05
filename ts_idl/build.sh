source /home/saluser/repos/ts_sal/setup.env

pip install -e .

make_idl_files.py all

python setup.py sdist
cd dist
pip install *.tar.gz
