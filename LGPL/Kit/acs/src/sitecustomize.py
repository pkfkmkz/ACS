import sys

first = True
for p in sys.path:
    if '/lib/python/site-packages' in p:
        if first:
            print("WARNING: The path 'lib/python/site-packages' has been deprecated, please edit your PYTHONPATH to use 'lib/pythonX.Y/site-packages' and remove every 'lib/python/site-packages' paths. There are two variables to aid in scripting the correct X.Y Python version: PYTHON_LIB_SUFFIX=lib/pythonX.Y and PYTHON_SITE_PACKAGES=lib/pythonX.Y/site-packages. List of offenders:")
            first = False
        print("WARNING: " + p)
