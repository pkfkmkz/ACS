# @(#) $Id: BaciHelper.py,v 1.1.1.1 2012/03/07 17:40:45 acaproni Exp $
#
# Copyright (C) 2001
# Associated Universities, Inc. Washington DC, USA.
#
# Produced for the ALMA project
#
# This library is free software; you can redistribute it and/or modify it under
# the terms of the GNU Library General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option) any
# later version.
#
# This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Library General Public License for more
# details.
#
# You should have received a copy of the GNU Library General Public License
# along with this library; if not, write to the Free Software Foundation, Inc.,
# 675 Massachusetts Ave, Cambridge, MA 02139, USA.  Correspondence concerning
# ALMA should be addressed as follows:
#
# Internet email: alma-sw-admin@nrao.edu
# "@(#) $Id: BaciHelper.py,v 1.1.1.1 2012/03/07 17:40:45 acaproni Exp $"
#
# who       when        what
# --------  ----------  ----------------------------------------------
# dfugate   2004/07/21  Created.
#------------------------------------------------------------------------------

'''
This module contains the implementation of helper functions/classes designed
to ease the pain of working with BACI.

TODO:
- addProperty does not create persistent CORBA objects at the moment. Needs
to be changed.
'''

__revision__ = "$Id: BaciHelper.py,v 1.1.1.1 2012/03/07 17:40:45 acaproni Exp $"

#--REGULAR IMPORTS-------------------------------------------------------------
from types import MethodType
#--CORBA STUBS-----------------------------------------------------------------
import CORBA
#--ACS Imports-----------------------------------------------------------------
from maciErrTypeImpl      import CannotGetComponentExImpl
from Acspy.Util.ACSCorba  import interfaceRepository

from ACSImpl.Double       import ROdouble, RWdouble
from ACSImpl.DoubleSeq    import ROdoubleSeq, RWdoubleSeq
from ACSImpl.Long         import ROlong, RWlong
from ACSImpl.LongSeq      import ROlongSeq, RWlongSeq
from ACSImpl.LongLong     import ROlongLong, RWlongLong
from ACSImpl.LongLongSeq  import ROlongLongSeq, RWlongLongSeq
from ACSImpl.ULong        import ROuLong, RWuLong
from ACSImpl.ULongSeq     import ROuLongSeq, RWuLongSeq
from ACSImpl.ULongLong    import ROuLongLong, RWuLongLong
from ACSImpl.ULongLongSeq import ROuLongLongSeq, RWuLongLongSeq
from ACSImpl.Pattern      import ROpattern, RWpattern
from ACSImpl.String       import ROstring, RWstring
from ACSImpl.StringSeq    import ROstringSeq
from ACSImpl.Enum         import getEnumClass
#--GLOBALS---------------------------------------------------------------------
IFR = None

#a dictionary mapping IFR IDs to interface descriptions. this is in place to
#save time (IFR operations are slow)
INTERFACE_DICT = {}
#------------------------------------------------------------------------------
def getIFR():
    global IFR
    if IFR is None:
        IFR = interfaceRepository()
    return IFR

def addProperty(comp_ref,
                prop_name,
                devio_ref=None,
                cdb_location=None,
                prop_type=""):
    '''
    This function automatically adds a BACI property implementation to a
    component and it is designed to be used from the initialize lifecyle
    method of components. If the IFR is not working correctly, this function 
    will NOT work at all as it is dependent upon the IFR to obtain the 
    property type.

    For those who want to know the nitty gritty details of this helper 
    function:
    
    1. It determines the correct CDB location for the property using the IFR 
    ID of the component (i.e., IDL name of the component) concatenated with 
    the name of the property
    
    2. It determines the proper ACS implementation of BACI property to use by
    looking it up in the IFR.
    
    3. It automatically adds the Python object (i.e., BACI property) to
    comp_ref. This member is named "__" + prop_name + "Object"
    
    4. It automatically adds the CORBA object property to comp_ref as well.
    This member is named "__" + prop_name + "CORBAObject"
    
    5. Finally, it automatically creates the "_get_" + prop_name method of
    comp_ref which returns 4.
    
    
    Parameters:
    - comp_ref is a reference to the component that will have the BACI
    property instance added to it. Under normal usage this would be "self"
    - prop_name is the name of the BACI property being created taken from
    the IDL file. An example could be "voltage".
    - devio_ref is a reference to a devIO object. If no devIO is provided,
    the default ACS devIO class will be used instead.
    - cdb_location is the location of this propertys definition within the
    XML schema defining the comp_ref component. An example could be
    "Mount:voltage". Please pay close attention to the fact this name has
    absolutely nothing to do with comp_refs instance name! It is not
    recommended to override this default parameter, but you can if the schema
    defining your component is following something other than the unofficial 
    standards set by the examples throughout ACS. Please be aware of the fact 
    this parameter may become deprecated in the near future also!
    - prop_type is unncessary to override IFF the IFR is working correctly.
    If this is not the case, the user can specify the propertys type
    directly here. An example could be "ROdouble"
    
    Returns: Nothing
    
    Raises: CannotGetComponentExImpl if real type of BACI property cannot be
            determined.
    '''
    #Make sure the IFR variable has been initialized
    getIFR()

    #string of the form 'IDL:alma/someModule/someInterface:1.0'
    comp_type = comp_ref._NP_RepositoryId
    modarray = comp_type.split(':')[1].split('/')
    
    #------------------------------------------------------------------------------
    #determine the name of the property within the ACS CDB
    if cdb_location == None:
        cdb_name = modarray[-1] + "/"
        cdb_name = cdb_name + prop_name
    else:
        cdb_name = cdb_location
    #------------------------------------------------------------------------------
    #if developer has not specified the property's type
    if prop_type == "":
        try:
            # Retrieve the property type from the module information
            newmod = __import__(modarray[1], globals(), locals(), modarray[2])
            component = getattr(newmod, modarray[2])
            attribute = getattr(component, '_d__get_%s' % prop_name)
            prop_ifr_name = attribute[1][0][1]
            prop_type = attribute[1][0][2]
        except AttributeError as ex:
            raise CannotGetComponentExImpl('The type of the property `%s` cannot be determined' % prop_name)

    #------------------------------------------------------------------------------
    #create the BACI property object and set it as a member of the component
    prop_py_name = "__" + prop_name + "Object"
    prop_corba_name = "__" + prop_name + "CORBAObject"
    
    #get the class implementation for the BACI property
    if prop_type == "ROstringSeq":
        prop_class = ROstringSeq

    elif prop_type == "ROdouble":
        prop_class = ROdouble

    elif prop_type == "RWdouble":
        prop_class = RWdouble

    elif prop_type == "ROdoubleSeq":
        prop_class = ROdoubleSeq

    elif prop_type == "RWdoubleSeq":
        prop_class = RWdoubleSeq

    elif prop_type == "ROlong":
        prop_class = ROlong

    elif prop_type == "RWlong":
        prop_class = RWlong

    elif prop_type == "ROlongSeq":
        prop_class = ROlongSeq

    elif prop_type == "RWlongSeq":
        prop_class = RWlongSeq

    elif prop_type == "ROlongLong":
        prop_class = ROlongLong

    elif prop_type == "RWlongLong":
        prop_class = RWlongLong

    elif prop_type == "ROlongLongSeq":
        prop_class = ROlongLongSeq

    elif prop_type == "RWlongLongSeq":
        prop_class = RWlongLongSeq

    elif prop_type == "ROuLong":
        prop_class = ROuLong

    elif prop_type == "RWuLong":
        prop_class = RWuLong
        
    elif prop_type == "ROuLongSeq":
        prop_class = ROuLongSeq

    elif prop_type == "RWuLongSeq":
        prop_class = RWuLongSeq

    elif prop_type == "ROuLongLong":
        prop_class = ROuLongLong

    elif prop_type == "RWuLongLong":
        prop_class = RWuLongLong

    elif prop_type == "ROuLongLongSeq":
        prop_class = ROuLongLongSeq

    elif prop_type == "RWuLongLongSeq":
        prop_class = RWuLongLongSeq

    elif prop_type == "ROpattern":
        prop_class = ROpattern

    elif prop_type == "RWpattern":
        prop_class = RWpattern

    elif prop_type == "ROstring":
        prop_class = ROstring

    elif prop_type == "RWstring":
        prop_class = RWstring
        
    #must handle user defined enums as well
    elif prop_type.startswith("RO") or prop_type.startswith("RW"):
        prop_class = getEnumClass(prop_ifr_name)
                
    else:
        msg = "The '" + str(prop_name) + "' property of type '" 
        msg = msg + str(prop_type) + "' from the the '" + str(comp_type)
        msg = msg + "' component type cannot be found within the IFR!"
        raise msg
    
    #create the pure python property object
    prop_obj = prop_class(cdb_name, comp_ref, devio_ref)
    #add the property object to the component
    comp_ref.__dict__[prop_py_name] = prop_obj
    
    #create the CORBA reference and set it as a member of the component
    corba_ref = prop_obj._this()
    comp_ref.__dict__[prop_corba_name] = corba_ref
    
    #------------------------------------------------------------------------------
    #create the function to return the property
    def genericFunction(*args, **moreargs):
        '''
        Generic implementation of an IDL method.

        Parameters:
        args - a tuple of arguments
        moreargs - a dictionary of arguments

        Returns: a reference to a BACI property 

        Raises: Nothing
        '''
        
        return comp_ref.__dict__[prop_corba_name]
    #------------------------------------------------------------------------------
    #register the generic function with the component
    comp_ref.__dict__["_get_" + prop_name] = MethodType(genericFunction, comp_ref)
    return
#----------------------------------------------------------------------------------
