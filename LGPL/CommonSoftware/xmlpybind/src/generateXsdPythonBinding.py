#! /usr/bin/env python
#*******************************************************************************
# ALMA - Atacama Large Millimiter Array
# (c) Associated Universities Inc., 2009 
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
# "@(#) $Id: generateXsdPythonBinding.py,v 1.6 2010/08/21 15:45:35 agrimstrup Exp $"
#
# who       when      what
# --------  --------  ----------------------------------------------
# agrimstrup  2009-12-15  created
#
from __future__ import print_function
import sys
import os
import re
import errno
from subprocess import call
from traceback import print_exc
import pyxb
import xmlpybind.EntitybuilderSettings


# Table containing all characters to be removed from a filename
DELTBL = ' !"#$%&\'()*+,-./:;<=>?@[\\]^`{|}~'

# In some of the ACS modules, the configuration file does not conform to the XML
# Schema.  Castor accepts these broken documents so this script should as well.
pyxb.RequireValidWhenParsing(False)

def find_schema_files(ebs, cfgfilename):
    '''Extract the file location and namespace information from the configuration.'''

    # xmljbind takes the location of the configuration as the base directory of the
    # schema files.  The relativePathSchemafile attribute then computes the location
    # from that point.
    basedir, cfgfile = os.path.split(cfgfilename)

    # The data we want is returned as a list of tuples containing the filename, with path,
    # and the namespace.
    flist = []
    nslist = []
    for cont in ebs.orderedContent():
        elem = cont.value
        # The XmlNamespace2JPackage elements are ignored because they contain information that
        # is only needed for the Java bindings.
        if elem._element().name() == 'EntitySchema':
            filename = os.path.join(basedir, elem.relativePathSchemafile, elem.schemaName)

            # The module's name is the same as the root of the file name.  Unlike the xmlNamespace,
            # I know that will be unique.
            nsname, ext = os.path.splitext(elem.schemaName)

            nslist.append(elem.xmlNamespace)
            
            # Some filenames are not legal Python module names, so we have to fix them as well.
            if re.compile(r'\A([a-zA-Z_])\w*\Z').match(nsname) is None:
                clist = list(nsname)
                for c in clist:
                    if c in DELTBL:
                        clist.remove(c)
                nsname = ''.join(clist)
            
            if os.path.isfile(filename):
                flist.append((filename, nsname))
            else:
                # It does not make sense to generate an incomplete set of bindings so, should
                # any specified schema file be missing, we must stop processing.
                raise IOError('%s not found' % filename)
    return flist, nslist

def get_site_packages():
    site_packages = 'lib/python/site-packages'
    if 'PYTHON_SITE_PACKAGES' in os.environ:
        site_packages = os.getenv('PYTHON_SITE_PACKAGES')
    return site_packages

def generate_bindings(pkgname, schema_file_list, schema_namespace_list, modpath='..', destdir=get_site_packages(), includes='', workdir='src'):
    '''Format and execute the pyxbgen command to build the bindings.'''

    # Generated Python bindings will live in the python/site-packages under the
    # name of the bindings file being processed.  The pre-compiled bindings will
    # also be stored there to eliminate the need for a separate archive directory.
    cmdstr = ['pyxbgen',
              '--module-prefix=%s' % pkgname,
              '--binding-root=%s/%s' % (modpath, destdir),
              '--archive-to-file=%s/%s/%s.wxs' % (modpath, destdir, pkgname),
              '--archive-path=%s/%s/bindings'%(modpath, workdir), ]

    # All bindings listed are processed by the same command.  This approach eliminates
    # special processing for schema dependencies but has not impact on standalone schemata.
    for srec in schema_file_list:
        cmdstr.append('-u %s -m %s' % srec)
    excmd = ' '.join(cmdstr)

    # The output of the pyxbgen command will be part of the build output because we
    # don't intercept stdout or stderr.
    retcode = call(excmd, shell=True)
    if retcode < 0:
        print("Child was terminated by signal", -retcode, file=sys.stderr)
    return retcode

def main(args, fopen=open):
    '''Generate Python bindings for the given specification'''
    site_packages = get_site_packages()

    # If the user fails to provide a file name, the script is going to fail anyway.
    # Better a helpful message than a cryptic exception.
    if not args:
        print("Usage: generateXsdPythonBinding <binding specification file>")
        return 0

    if len(args) >= 2:
        modpath = args[1]
    else:
        modpath = ".."

    if len(args) >= 3:
        destdir = args[2]
    else:
        destdir = site_packages

    if len(args) >= 4:
        includes = ':'+args[3]
    else:
        includes = ''

    if len(args) >= 5:
        workdir = args[4]
    else:
        workdir = os.getcwd().split('/')[-1]

    try:
        # Previously compiled bindings are brought into the build by mistake
        # so we link to any .wxs files we might need excluding any previously
        # built version of this set.
        binds = []
        try:
            os.mkdir(modpath + '/' + workdir + '/bindings')
        except:
            pass
        oldbinding = '%s.wxs' % args[0].strip()
        for p in (includes.split(':') + sys.path):
            if not p: continue
            try:
                fl = os.listdir(p)
            except:
                continue
            for b in [bndg for bndg in fl if bndg.endswith('.wxs') and bndg != oldbinding and bndg not in binds]:
                try:
                    os.symlink(os.path.join(p,b), os.path.join(modpath + '/' + workdir + '/bindings', b))
                    binds.append(b)
                except OSError as e:
                    if e.errno == errno.EEXIST:
                        continue
                    else:
                        raise 
                
        # Retrieve the settings for this set of bindings.
        #
        # By convention, XSD binding files are stored in the idl directory of the
        # module being compiled.  They are XML documents that follow the
        # EntitybuilderSettings schema.
        xml = fopen('%s/idl/%s.xml' % (modpath, args[0].strip()))
        ebs = xmlpybind.EntitybuilderSettings.CreateFromDocument(xml.read())

        flist,nslist = find_schema_files(ebs, xml.name)

        # If no schema were provided in the specification, the list will be empty.
        if flist:
            rv =  generate_bindings(args[0], flist, nslist, modpath, destdir, includes, workdir)
        else:
            print("Specification %s contains no schema information." % args[0], file=sys.stderr)
            rv = 0

        # Clean up the binding cache
        rc = call('rm -rf ' + modpath + '/' + workdir + '/bindings', shell=True)
        
        return rv
    except Exception as e:
        print("%s: %s" % (args[0], e), file=sys.stderr)

        # Clean up the binding cache
        rc = call('rm -rf ' + modpath + '/' + workdir + '/bindings', shell=True)

        return -1
        
if __name__ == '__main__': # pragma: no cover
    sys.exit(main(sys.argv[1:]))


#
# ___oOo___
