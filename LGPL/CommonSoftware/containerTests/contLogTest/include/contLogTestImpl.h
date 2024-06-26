#ifndef _CONT_LOG_TEST_H
#define _CONT_LOG_TEST_H
/*******************************************************************************
*    ALMA - Atacama Large Millimiter Array
*    (c) Associated Universities Inc., 2002 
*    (c) European Southern Observatory, 2002
*    Copyright by ESO (in the framework of the ALMA collaboration)
*    and Cosylab 2002, All rights reserved
*
*    This library is free software; you can redistribute it and/or
*    modify it under the terms of the GNU Lesser General Public
*    License as published by the Free Software Foundation; either
*    version 2.1 of the License, or (at your option) any later version.
*
*    This library is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*    Lesser General Public License for more details.
*
*    You should have received a copy of the GNU Lesser General Public
*    License along with this library; if not, write to the Free Software
*    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*
* "@(#) $Id: contLogTestImpl.h,v 1.5 2008/10/07 09:18:09 cparedes Exp $"
*
* who       when        what
* --------  ----------  ----------------------------------------------
* eallaert  2007-11-05  initial version
*/

#ifndef __cplusplus
#error This is a C++ include file and cannot be used from plain C
#endif

///This example is unique because it is derived from CharacteristicComponent's
///superclass, ACSComponent.
#include <acscomponentImpl.h>

///This is the CORBA stub client header for ACSErrTypeCommon.idl where the 
///definition of the CORBA exception is found.
#include <ACSErrTypeCommon.h>

/**
 *  The empty CORBA servant interface, POA_contLogTest::TestLogLevelsComp,
 *  is obtained from this header file and is automatically generated from 
 *  contLogTest's Interface Definition File (i.e., contLogTest.idl) 
 *  by CORBA.
 */
#include <contLogTest_IFS.h>
 
/**
 * All components should inherit from CharacteristicComponentImpl or it's 
 * superclass, ACSComponentImpl, to remain  compatiable with ACS tools such 
 * as objexp (i.e., a GUI used to manipulate components).  This class also 
 * derives from POA_contLogTest::TestLogLevelsComp which is a class automatically 
 * generated by CORBA from contLogTest's IDL file.
 * @version "@(#) $Id: contLogTestImpl.h,v 1.5 2008/10/07 09:18:09 cparedes Exp $"
 */
class TestLogLevelsComp: public virtual acscomponent::ACSComponentImpl,     //Component superclass
		  public POA_contLogTest::TestLogLevelsComp    //CORBA servant stub
{    
  public:
    /**
     * Constructor
     * @param poa Poa which will activate this and also all other components. Developers need
     * not be concerned with what a PortableServer does...just pass it to the superclass's
     * constructor.
     * @param name component's name. All components have a name associated with them so other 
     * components and clients can access them.
     */
    TestLogLevelsComp(
	       const ACE_CString& name,
	       maci::ContainerServices * containerServices);
    
    /**
     * Destructor
     */
    virtual ~TestLogLevelsComp();
    
    /* --------------------- [ CORBA interface ] ----------------------*/    
    /**
     * Implementation of IDL getLevels().
     * @throw ACSErrTypeCommon::CouldntPerformActionEx
     * @htmlonly
       <br><hr>
       @endhtmlonly
     */     
    virtual ::contLogTest::LongSeq* 
    getLevels ();

    virtual void 
    logDummyMessages (const ::contLogTest::LongSeq & levels);
    maci::ContainerServices* cs;
    
  private:
	  ::contLogTest::LongSeq levels[5];
};
/*\@}*/
/*\@}*/

#endif /*!_CONT_LOG_TEST_H*/



