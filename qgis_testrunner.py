#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
***************************************************************************
    Launches a unit test inside QGIS and exit the application.

    Arguments:

    accepts a single argument with the package name in python dotted notation,
    the program tries first to load the module and launch the `run_all`
    function of the module, if that fails it considers the last part of
    the dotted path to be the function name and the previous part to be the
    module.

    Extra options for QGIS command line can be passed in the env var
    QGIS_EXTRA_OPTIONS

    Example run:

    # Will load geoserverexplorer.test.catalogtests and run `run_all`
    QGIS_EXTRA_OPTIONS='--optionspath .' \
    GSHOSTNAME=localhost python qgis_testrunner.py \
        geoserverexplorer.test.catalogtests

    # Will load geoserverexplorer.test.catalogtests and run `run_my`
    GSHOSTNAME=localhost python qgis_testrunner.py \
        geoserverexplorer.test.catalogtests.run_my

    ---------------------
    Date                 : May 2016
    Copyright            : (C) 2016 by Alessandro Pasotti
    Email                : apasotti at boundlessgeo dot com
***************************************************************************
*                                                                         *
*   This program is free software; you can redistribute it and/or modify  *
*   it under the terms of the GNU General Public License as published by  *
*   the Free Software Foundation; either version 2 of the License, or     *
*   (at your option) any later version.                                   *
*                                                                         *
***************************************************************************
"""

__author__ = 'Alessandro Pasotti'
__date__ = 'May 2016'

import os
import re
import sys
import signal
import importlib
from pexpect import run
from pipes import quote

from qgis.utils import iface

def eprint(text):
    sys.__stderr__.write(text + "\n")

def __get_test_function(test_module_name):
    """
    Load the test module and return the test function
    """
    print("QGIS Test Runner - Trying to import %s" % test_module_name)
    try:
        test_module = importlib.import_module(test_module_name)
        function_name = 'run_all'
    except ImportError, e:
        # Strip latest name
        pos = test_module_name.rfind('.')
        if pos <= 0:
            raise e
        test_module_name, function_name = test_module_name[:pos], test_module_name[pos+1:]
        print("QGIS Test Runner - Trying to import %s" % test_module_name)
        try:
            test_module = importlib.import_module(test_module_name)
        except ImportError:
            return None
    return getattr(test_module, function_name, None)

if iface is None:
    """
    Launch QGIS and passes itself as an init script
    """
    sys.path.append(os.getcwd())
    test_module_name = sys.argv[-1]
    if __get_test_function(test_module_name) is None:
        print("QGIS Test Runner - [ERROR] cannot load test function from %s" % test_module_name)
        sys.exit(1)
    try:
        me = __file__
    except NameError:
        me = sys.argv[0]
    os.environ['QGIS_DEBUG'] = '1'
    args = [
        'qgis',
        os.environ.get('QGIS_EXTRA_OPTIONS', ''),
        '--nologo',
        '--noversioncheck',
        '--code',
        me,
        test_module_name, # Must be the last one!
    ]
    command_line = ' '.join(args)
    print("QGIS Test Runner - launching QGIS as %s ..." % command_line)
    out, returncode = run("sh -c " + quote(command_line), withexitstatus=1)
    assert returncode is not None
    print("QGIS Test Runner - QGIS exited.")
    ok = out.find('(failures=') < 0 and \
        len(re.findall(r'Ran \d+ tests in\s',
                       out, re.MULTILINE)) > 0
    print('='*60)
    if not ok:
        print(out)
    else:
        eprint(out)
    if len(out) == 0:
        print("QGIS Test Runner - [WARNING] subprocess returned no output")
    print('='*60)

    print("QGIS Test Runner - %s bytes returned and finished with exit code: %s" % (len(out), 0 if ok else 1))
    sys.exit(0 if ok else 1)

else: # We are inside QGIS!
    # Start as soon as the initializationCompleted signal is fired
    from qgis.core import QgsApplication
    from PyQt.QtCore import QDir
    from qgis.utils import iface

    # Add current working dir to the python path
    sys.path.append(QDir.current().path())

    def __run_test():
        """
        Run the test specified as last argument in the command line.
        """
        eprint("QGIS Test Runner Inside - starting the tests ...")
        try:
            test_module_name = QgsApplication.instance().argv()[-1]
            function_name = __get_test_function(test_module_name)
            if function_name is None:
                eprint("QGIS Test Runner Inside - [ERROR] cannot load test function from %s" % test_module_name)
            function_name()
        except Exception, e:
            eprint("QGIS Test Runner Inside - [ERROR] Exception: %s" % e)
        app = QgsApplication.instance()
        os.kill(app.applicationPid(), signal.SIGTERM)
    iface.initializationCompleted.connect(__run_test)
