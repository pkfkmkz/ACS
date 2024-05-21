#ifndef _parameter_task_H
#define _parameter_task_H
/*******************************************************************************
* ALMA - Atacama Large Millimiter Array
* (c) European Southern Observatory, 2005 
* 
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
* 
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
* 
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*
* "@(#) $Id: parameterTask.h,v 1.13 2008/10/09 07:22:33 cparedes Exp $"
*
* who       when      what
* --------  --------  ----------------------------------------------
* bjeram  2005-01-19  created
*/

/************************************************************************
 *
 *----------------------------------------------------------------------
 */

#ifndef __cplusplus
#error This is a C++ include file and cannot be used from plain C
#endif

#include <map>
#include <memory>
#include <vector>
#include "taskComponent.h"
#include <xercesc/dom/DOMDocument.hpp>
#include <ParamSetDef.h>
#include <task.h>

namespace ACS 
{
	/**
	 * The parameterTask class is the (abstract) base class for all ACS-based tasks 
	 * which used the parameter handling library provided by ACS.
	 *
	 * In order to make a concrete implementation, this class must be extended 
	 * (i.e. sub-classed) and the "go" method (inherited from the ACS::Task interface)
	 * must be implemented in the sub-class.
	 */
	class parameterTask :  public virtual acscomponent::ACSComponentImpl,
		public virtual POA_ACS::TaskComponent, public ACS::Task
	{
		public:
			/**
			 * Constructor
			 * @param name The name of the (task) component
			 * @param containerServices The container services for the (task) component
			 */
			parameterTask(const ACE_CString& name, maci::ContainerServices* containerServices);
	
			/**
			 * Destructor
			 */
			virtual ~parameterTask(){}

			/**
			 * The required run method (for the CORBA/IDL interface, TaskComponent).
			 * @param parameters The parameters/arguments supplied on the command line.
			 * @param fileName The (base) name (without extension) of the meta-data xml file containing
			 * meta-information about the task.
             * @throw taskErrType::TaskRunFailureEx
			 */
			virtual void run (const ACS::StringSequence & parameters, const char* fileName); 

		private:
            /*
             * @throw invalid_argument
            */
			void buildParameterMap(const ACS::StringSequence & parameters, const std::string & baseFileName) ;
            /*
             * @throw std::invalid_argument
            */
			void checkPosition(std::string::size_type currPosition, unsigned int length, const std::string & msg) ;
            /*
             * @throw std::domain_error
            */
			std::string buildParameterSetXML(const std::string & fileNamePrefix);
			XERCES_CPP_NAMESPACE::DOMElement* createBoolElement(const std::string & paramName, const std::vector<std::string> & values, XERCES_CPP_NAMESPACE::DOMDocument*);
			XERCES_CPP_NAMESPACE::DOMElement* createIntElement(const std::string & paramName, const std::vector<std::string> & values, XERCES_CPP_NAMESPACE::DOMDocument*);
			XERCES_CPP_NAMESPACE::DOMElement* createIntArrayElement(const std::string & paramName, const std::vector<std::string> & values, XERCES_CPP_NAMESPACE::DOMDocument*);
			XERCES_CPP_NAMESPACE::DOMElement* createDoubleElement(const std::string & paramName, const std::vector<std::string> & values, XERCES_CPP_NAMESPACE::DOMDocument*);
			XERCES_CPP_NAMESPACE::DOMElement* createDoubleArrayElement(const std::string & paramName, const std::vector<std::string> & values, XERCES_CPP_NAMESPACE::DOMDocument*);
			XERCES_CPP_NAMESPACE::DOMElement* createStringElement(const std::string & paramName, const std::vector<std::string> & values, XERCES_CPP_NAMESPACE::DOMDocument*);
			XERCES_CPP_NAMESPACE::DOMElement* createStringArrayElement(const std::string & paramName, const std::vector<std::string> & values, XERCES_CPP_NAMESPACE::DOMDocument*);
			XERCES_CPP_NAMESPACE::DOMElement* createSimpleElement(const std::string & paramName, const std::vector<std::string> & values, XERCES_CPP_NAMESPACE::DOMDocument *doc, 
				const std::string & paramType);
			XERCES_CPP_NAMESPACE::DOMElement* createArrayElement(const std::string & paramName, const std::vector<std::string> & values, 
				XERCES_CPP_NAMESPACE::DOMDocument *doc, const std::string & paramType);

            /*
             * @throw invalid_argument
            */
			std::vector<std::string> parseBoolElement(const std::string & valueString);
            /*
             * @throw invalid_argument
            */
			std::vector<std::string> parseIntElement(const std::string & valueString);
            /*
             * @throw invalid_argument
            */
			std::vector<std::string> parseIntArrayElement(const std::string & valueString);
            /*
             * @throw invalid_argument
            */
			std::vector<std::string> parseDoubleElement(const std::string & valueString);
            /*
             * @throw invalid_argument
            */
			std::vector<std::string> parseDoubleArrayElement(const std::string & valueString);
            /*
             * @throw invalid_argument
            */
			std::vector<std::string> parseStringElement(const std::string & valueString);
            /*
             * @throw invalid_argument
            */
			std::vector<std::string> parseStringArrayElement(const std::string & valueString);

			// map to hold the name/value(s) information from the parsed command line
			std::map<std::string, std::vector<std::string>> parameterMap; 

			// the in-memory DOM document built from the parameters
			std::shared_ptr<XERCES_CPP_NAMESPACE::DOMDocument> domDocument;

			// the parameter set definition 
			std::shared_ptr<Parameters::ParamSetDef> paramSetDef;
	};

}
#endif /*!_H*/

