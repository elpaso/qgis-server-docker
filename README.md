qgis-desktop-docker
============================

This is a simple container for testing QGIS Desktop and for
executing unit tests inside a real QGIS instance.


# Features

The image contains QGIS 2.14 official build installed from debian GIS
repositories and a python script to run unit tests inside QGIS.

You can use this docker to test QGIS or to run unit tests inside QGIS,
xvfb is available and running as a service inside the container to allow
for fully automated headless testing in Travis CI jobs.


# Building

You can build the image with:

```
# Place your IP address here, if you want to use apt-catcher note that APT
# catcher is not enabled by default, in order to enable it, you should
# uncomment two lines in the docker file (see comments in Dockerfile).
$ export ADDR=192.168.1.1
$ docker build -t qgis-desktop --build-arg APT_CATCHER_IP=$ADDR .
```

# Running QGIS

To run a container, assuming that you want to use your current display to use
QGIS and the image is named `qgis-desktop`:

```
# Allow connections from any host
$ xhost +
$ docker run --rm  -it --name qgis_desktop -v /tmp/.X11-unix:/tmp/.X11-unix  \
    -e DISPLAY=unix$DISPLAY qgis-desktop qgis
```

# Running unit tests inside QGIS

Suppose that you have local directoty containing the tests to execute into
QGIS:

```
/my_tests/travis_tests/
├── faketest.py
├── __init__.py
├── tclass.py
└── test_TravisTest.py
```

To run the tests inside the container, you have to mount the directory that
contains the tests (e.g. your local directory `/my_tests`) into a volume
that is accessible by the container.


```
$ docker run -d --name qgis-desktop -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /my_tests/:/tests_directory -e DISPLAY=:99 qgis-desktop

```

When done, you can invoke the test runnner (output follows, the failure is
expected):

```
$ docker exec -it qgis-desktop sh -c "qgis_testrunner.sh travis_tests.test_TravisTest.run_fail"
QGIS Test Runner - Trying to import travis_tests.test_TravisTest
QGIS Test Runner - launching QGIS as qgis --optionspath /qgishome --nologo --noversioncheck --code /usr/bin/qgis_testrunner.py travis_tests.test_TravisTest ...
QGIS Test Runner - QGIS exited with returncode: 143
Warning: QCss::Parser - Failed to load file  "/style.qss"
QInotifyFileSystemWatcherEngine::addPaths: inotify_add_watch failed: No such file or directory
Warning: QFileSystemWatcher: failed to add paths: /root/.qgis2//project_templates
QGIS Test Runner Inside - starting the tests ...
QGIS Test Runner - Trying to import travis_tests.test_TravisTest
test_QGIS_is_available (travis_tests.test_TravisTest.TravisTestsTests)
Test QGIS bindings can be imported ... ok
test_funca (travis_tests.test_TravisTest.TravisTestsTests)
Test funcA function ... ok
test_funcb (travis_tests.test_TravisTest.TravisTestsTests)
Test funcB function ... ok
test_funcb_fails (travis_tests.test_TravisTest.TravisTestsTests)
Test funcB function fails ... FAIL

======================================================================
FAIL: test_funcb_fails (travis_tests.test_TravisTest.TravisTestsTests)
Test funcB function fails
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/tests_directory/travis_tests/test_TravisTest.py", line 33, in test_funcb_fails
    self.assertEqual(c.funcB(), '')
AssertionError: 'B' != ''

----------------------------------------------------------------------
Ran 4 tests in 0.001s

FAILED (failures=1)
```

## Options for the test runner

The env var `QGIS_EXTRA_OPTIONS` defaults to
```
ENV QGIS_EXTRA_OPTIONS="--optionspath /qgishome"
```
contains extra parameters that are passed to QGIS by the test runner.

The purpose of `/qgishome` is to contain a QGIS settings file that disables
startup tips modal dialog.
