#! /usr/bin/env python
#*******************************************************************************
# ALMA - Atacama Large Millimiter Array
# Copyright (c) European Southern Observatory, 2014 
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
#
# who       when      what
# --------  --------  ----------------------------------------------
# acaproni  2014-06-05  created
#
from os import chdir, getcwd, mkdir, listdir
from os.path import exists, isdir, split, join
from subprocess import call
from shutil import rmtree, copy
from time import strftime

class DocsGenerator(object):
    '''
    Generates the documentation for a given release
    (note that the API is generated by another class; this one 
    deals with MS Word documents, HTML pages like that of the command center
    and so on).
    
    All the documentation goes into WebFolder.getDocsFolder().
    Such folder will contains the docs,pdf, the index.html and so on.
    
    To generate the documentation, this script checkout and run make in ACS/Documents
    '''
    
    def __init__(self, webFolder, svnUrlHelper):
        '''
        Constructor
        
        @param webFolder: the web folder
        @param acsTag: the tag to build API docs
        '''
        assert webFolder is not None
        self.webFolder=webFolder
        assert svnUrlHelper is not None
        self.svnUrlHelper=svnUrlHelper

    def buildDocs(self):
        '''
        Build the documents in ACS/Documents by calling Make
        
        @param webFolder: the WebFolder to checkout in the temp folder
        @return False in case of error; True otherwise
        '''
        self.webFolder.chdirTemp()
        
        if not exists("ACS/Documents"):
            print getcwd()+"/ACS/Documents not found"
            return True
        if not isdir("ACS/Documents"):
            print getcwd()+"/ACS/Documents is not a folder"
            return True
        
        chdir("ACS/Documents")
        
        if exists("out"):
            rmtree("out")
        
        mkdir("out")
        
        cmd=[]
        cmd.append("make")
        cmd.append("all")
        ret=call(cmd)
        if ret!=0:
            print "Error running make in ACS/Documents to generate documents"
            return False
        
        self.genIndex()
        self.copyDocsIntoWeb()
        
        return True
    
    def copyDocsIntoWeb(self):
        '''
        Copy the generated docs into the web folder
        '''
        self.webFolder.chdirTemp()
        chdir("ACS/Documents/out")
        destFolder=self.webFolder.getWebFolder()
        
        filesToCopy = listdir(".")
        
        for file in filesToCopy:
            copy(file,self.webFolder.getDocsFolder())
    
    def genIndex(self):
        '''
        Copy the index.html on the Data folder of this python package into the web page
        
        It also fix the version of ACS and add the creation timestamp at the bottom
        '''
        this_dir, this_filename = split(__file__)
        DATA_PATH = join(this_dir, "Data", "index.html")
        with open(DATA_PATH) as f:
            content = f.readlines()
        
        self.webFolder.chdirTemp()
        chdir("ACS/Documents/out")
        
        with open("index.xml", 'w') as f:
            for line in content:
                if "</body>" in line:
                    line=line.replace("</body>","<HR><SMALL>Created "+strftime("%Y/%m/%d at %H:%M:%S")+"</SMALL>\n</body>")
                elif "ACS-YYYY.NN" in line:
                    line=line.replace("ACS-YYYY.NN",self.svnUrlHelper.getTag())
                f.write(line)
#
# ___oOo___
