#ifndef _STRING_PARAM_H
#define _STRING_PARAM_H
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
* "@(#) $Id: StringParam.h,v 1.4 2006/11/29 23:01:26 sharring Exp $"
*
* who       when      what
* --------  --------  ----------------------------------------------
* sharring  10/27/04  created
*/

#ifndef __cplusplus
#error This is a C++ include file and cannot be used from plain C
#endif

#include <Param.h>
#include <string>

/** @file StringParam.h */

namespace Parameters {

	/**
	 * StringParam class used to support OFFLINE tasks
	 */
	class StringParam : public Parameters::Param
	{    
	  public:
	    /**
	     * Constructor
	     */
	    StringParam();

	    /**
	     * Constructor
	     */
	    StringParam(const std::string & nameVal, const std::string & stringVal);
	    
	    /**
	     * Destructor
	     */
	    virtual ~StringParam();
	    
	    /*
	     * Accessor for the value_m.
	     * @return the value as a string.
	     */
	    std::string getValue();

	    /*
	     * Accessor for the type, e.g. "bool" or "int" etc.
	     * @return the type as a string.
	     */
	    virtual std::string getType();

		protected:
		/**
		 * Used to create the value portion of the toString (XML) string.
		 * Different concrete implementations may do this differently, but
		 * they will all have such a method.
		 */
		virtual std::string valueToString();

	  private:
	    std::string value_m;
	};

}
#endif /*!_STRING_PARAM_H*/



