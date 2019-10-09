*****************
Better Title Here
*****************

Procedure
=========

Our conda Docker environment is specially provided by the following `repository. <https://cloud.docker.com/u/lsstts/repository/docker/lsstts/develop-env-conda>`_
That image is built with the following `Dockerfile. <https://github.com/lsst-ts/ts_Dockerfiles/blob/develop/develop-env/conda/Dockerfile>`_

If you need a ticket version of the xml or of SAL, you can do so by cloning the ts_Dockerfiles repository and running the following command.
Updating the image with new xml or sal is fairly straightforward, provided that the setup instructions has not changed across versions.
Incidentally, only SAL 3.10.x has been tested with this setup.
In the directory where the Dockerfile is located invoke the following shell command.

.. code::

    docker build --build-args xml_branch={xml_tag},sal_branch={sal_branch} -t lsstts/develop-env-conda:xml{version}_sal{version}

There are already several pre-built versions of this image with different versions of ts_xml.
They are already located on dockerhub as tags of the image.
To get started with development, run the image with the following command.

.. code::

    docker run -v {develop_mount}:{develop_location} lsstts/develop-env-conda:xml{version}_sal{version}

By default, the following packages are available for use.

* ts_xml
* ts_sal
* ts-salobj - installed as a conda package
* ts_idl
* OpenSplice - installed as an RPM package hosted by the LSST nexus repository
* pydds - Part of OpenSplice
* conda-build

Working with Conda
------------------
Using Conda is fairly straightforward.
Conda is a package manager which works by managing environments.
Environments are isolated spaces and work best for managing individual software package requirements.
Our development environment carries alot of commonalities and therefore the base environment is already setup with many of the important dependencies.
If you create a new environment, the packages from the base environment are inherited into the new environment,
however since our stack is intermingled with environment manipulation, stability of our environment becomes a luxury and so try different things at your own risk.

By default when starting the image, conda is already activated and ready for your use.
Installing a package is fairly straightforward, you just type the name of a package after `conda install`.
Removing a package is simple, just type the name of a package after `conda remove`.
Finding packages that you can install is pretty simple, just search the anaconda-cloud `site <https://anaconda.org/>`_ for various packages.
Conda uses channels to divide their package repos.
Like dockerhub, the channels can be individuals or an organization.
This allows for packages that are the same name to exist on the site.
It also means that an organization can provided their own specialized recipes for their purposes.
Telescope and Site software has a channel that hosts some conda packages.
It is located `here <https://anaconda.org/lsstts>`_.
By default there are several channels installed with your conda environment.
To install a package using a particular channel, simply type the following into your prompt.

.. code::

    conda install -c lsstts ts-salobj

-c  stands for channel and the argument is the name of the channel.

You can search the website for packages to install into your environment.

.. code::

    conda install {package}
    conda remove {package}
    conda create -n {name_of_environment} [{list of packages to install}]
    conda activate {name_of_environment}


Creating Conda packages
-----------------------
Creating a Conda package requires a Conda recipe.
A recipe consists of one or more files.

::

    .
    ├── build.sh(optional)
    └── meta.yaml(required)

The meta.yaml file contains the metadata for the recipe.
This is where you put the name and version of the package, as well as, the location of the source code.
This file is mandatory for making `conda-build` work.
The other files are optional but useful.
The build script file is where the build steps for installing/building a package are located.
The third file is the run_tests.[sh,bat,py,pl] which tells the recipe how to run the tests.

The meta.yaml file is considered the core file for the recipe.
The file consists of sections, each of which detail a particular aspect of the recipe.

* package
* source
* build
* requirements
* test
* outputs
* about
* extra

The package section is where information such as the name and version of the package go.

The source section contains the information to find the source code for the package.
This section requires one of three paths to be considered complete.
The first path is to use a git repository.
The second path is to use a hg repository.
The final path is to use an archive file.
The two VCS paths can be a local or remote repository.
The archive file can either be a local or server file.
Word of caution, conda divides environment variables that it sets into the type of source that is used.
So recipes which grab metadata from the source will have different environment variables set.

The build section contains the information to build the package.
This section has options that control on what OS the package can be built, you can see it in the example below, how it is used to skip building on Windows.
You can also pass environment variables,
which is not recommended by the official documentation,
but until we solve our reliance on environment variables, we'll just break the guidelines.
This is how we work-around the issue until someone comes up with a better solution.
For one step installation mechanisms, you can use the script key to set a command to run that installs the package.

The requirements section specifies the dependencies for both building and running the package.
The host key is a list of conda packages required to build the package that should be installed on the host.
The runtime key is a list of conda packages required to run the package when installed.
This means that python is both a host and runtime dependency and any python packages used should be listed as runtime dependencies.
Any setuptools extensions should be listed as a host dependency.
It is important to note that any pip packages are not considered usable by conda-build, so those packages must be installable as conda packages.

The test section specifies the dependencies for running unit tests for the package.
The dependencies are inherited from the build section as well.

The outputs section outlines the one or more packages that are built from this recipe.
This section allows for greater granularity over the output of package(s).
For instance, this allows for recipes which create more than one package.
This is useful for metadata packages which are packages that group related packages together.

The about section is for specifying metadata for the package.
The extra section is used for information outside of the package such as metadata for repository hosting service.

The build script is either a unix shell script or Windows batch file that contains the necessary steps to install/build the package.
This script can contain any valid syntax and commands for that particular scripting language.

The test script runs during the testing portion of the build and executes any commands found in those scripts.
For more information on this topic, check the official `documentation. <https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html>`_

Once you think you have a working recipe, you can attempt to build it by invoking the following command.

.. code::

    conda-build {recipe_location}

Conda-build will then run through the process by installing the package and running whatever tests(unit tests and import tests) that you specified in the recipe.

An Example CSC
==============

ts_ATDome is a CSC that should be a relative easy example to port to a conda package.
The first step that I like to use, is to determine what the dependencies are for the package.
In EUPs, you can find the dependencies through the {name_of_product}.table.
This only lists the high-level EUPs products so there may be unspecified dependencies.
In this case, there are three dependencies listed for ts_ATDome.

* ts_config_attcs
* sconsUtils
* ts_salobj

We don't need sconsUtils anymore because its only purpose was to provide EUPs integration with scons.
ts_salobj is already available as a conda package which means it can be easily listed as a dependency.
So the only dependency we need to deal with is the ts_config_attcs package.
But we'll come back to that problem later.

Now the next step is to determine how to add the package to the python path.
EUPs works by manipulating the environment to add python packages to the PYTHONPATH environment variable.
However, we can leverage the standard python package installation method to handle that for us.
All we need to do is add a setup.py file to the root package directory of `ts_ATDome <https://github.com/lsst-ts/ts_ATDome>`_.

Following the `TSSW gitflow workflow <https://tssw-developer.lsst.io>`_, we create a branch and you know the rest at this point.
Using the `setup.py <https://github.com/lsst-ts/ts_sal/blob/develop/setup.py>`_ in the ts_sal repo as an example, we can just build a simple one.

.. code:: python

    from setuptools import setup, find_namespace_packages

    install_requires = []
    tests_requires = ["pytest", "pytest-flake8"]
    dev_requires = install_requires + tests_requires + ["documenteer[pipelines]"]

    setup(
        name="ts_ATDome",
        description="Installs python code for ts_ATDome.",
        setup_requires=["setuptools_scm"],
        package_dir={"": "python"},
        packages=find_namespace_packages(where="python"),
        scripts=["bin/run_atdome.py"],
        tests_require=tests_require,
        extras_require={"dev": dev_requires},
        license="GPL"
    )

This file will add the ts_ATDome package to the package-sites directory of the python install, which is included as the default spot to look for python packages.
You can test your file by using `pip install`.
If no errors come up, then you are all good to go.
However, if errors do pop up, then check the following

* typos in the parameters, especially the require fields

The next step is to check out `ts_recipes <https://github.com/lsst-ts/ts_recipes>`_, which is where our conda recipes are located.
Create a branch using the gitflow workflow.
Now create a subdirectory called ts_ATDome.
This directory is where the recipe will go.
Create a meta.yaml file within this directory.

.. code:: yaml

    { % set data=load_setup_py_data() % }

    package:
      name: ts-ATDome
      version: {{ data.get('version') }}

    source:
      git_url: https://github.com/lsst-ts/ts_ATDome
      git_rev: {ticket_branch}

    build:
      skip: True #[win]
      script: python -m pip install --ignore-installed --no-deps .
      script_env:
        - PATH
        - PYTHONPATH
        - LD_LIBRARY_PATH
        - LSST_SDK_INSTALL
        - OSPL_HOME
        - LSST_DDS_DOMAIN
        - PYTHON_BUILD_VERSION
        - PYTHON_BUILD_LOCATION

    requirements:
      host:
        - python
        - pip
        - setuptools_scm
        - setuptools
      run:
        - python
        - setuptools
        - setuptools_scm
        - ts-salobj

    test:
      requires:
        - pytest
        - pytest-flake8
        - pytest-cov
      commands:
        - py.test --pyargs lsst.ts.ATDome tests/

This file will get you through the steps of building and testing the conda package.
You can test it and see if you run into any issues.
If you run into an issue of a package not being found such as pytest-flake8, run the following.

.. code::

    conda config --add channels forge

This is how you permanently add channels to your configuration.

For ts_config_attcs support, type the following into your shell.

.. code::

    TS_CONFIG_ATTCS=$HOME/repos/ts_config_attcs

Once you have a built package, you can install it by typing in the following

.. code::

    conda install {location_of_package} # this is found in the final line of a successful conda build

Once installed, you can verify to your standards whether the package works.
Once tested to your satisfaction, you can now upload the package to the repository.
TBD, if that's the appropriate solution.
You will need an account on the anaconda-cloud service and to be added to the lsstts channel on there.
You can be added to the channel by giving an admin, your username on anaconda-cloud.
To upload a package, invoke the following in your terminal

.. code::

    anaconda upload -c lsstts {location_of_conda_package} #again found on the last line of a successful conda build

Upon success, your package will now be uploaded to the channel for distribution purposes.

Q and A
=======

What about EUPs's tagging system?
    DM has not established what they are going to do in this situation.
What about applications that integrate with the LSST Science Pipeline(LSP)?
    DM has agreed to support that software becoming conda packages.
