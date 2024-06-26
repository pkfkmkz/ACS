#ifndef _PARAMETER_SET_H
#define _PARAMETER_SET_H
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
* "@(#) $Id: ParameterSet.h,v 1.12 2010/04/27 12:20:58 htischer Exp $"
*
* who       when      what
* --------  --------  ----------------------------------------------
* sharring  09/27/04  created
*/

#ifndef __cplusplus
#error This is a C++ include file and cannot be used from plain C
#endif

#include <map>
#include <memory>
#include <string.h>
#include <stdexcept>
#include <stdlib.h>
#include <xercesc/dom/DOMLSParser.hpp>
#include <xercesc/dom/DOMElement.hpp>
#include <xercesc/dom/DOMNode.hpp>
#include <xercesc/util/PlatformUtils.hpp>
#include <ParamStrX.h>
#include <InMemoryXmlData.h>
#include <ParamSetDef.h>
#include <BoolParam.h>
#include <IntParam.h>
#include <IntArrayParam.h>
#include <DoubleArrayParam.h>
#include <DoubleParam.h>
#include <StringParam.h>
#include <StringArrayParam.h>
#include <parameterConstants.h>

/** @file ParameterSet.h */

namespace Parameters {

	/**
	 * ParameterSet class used to support OFFLINE tasks
	 */
	class ParameterSet
	{    
		public:
			/********************** Constructors/Destructors ***************************/

			/**
			 * Constructor
			 * @param xmlFileName the name of the file containing the XML document defining the parameter set
			 * Note: the file name must exist on the machine where the Task component is running. If this is 
			 * not the case, the file name will be meaningless and you should, instead, use the other constructor, 
			 * below, deals with the data solely in memory. 
			 */
			ParameterSet(std::string xmlFileName);

			/**
			 * Constructor
			 * @param InMemoryXmlData contains the XML data (as a InMemoryXmlData object) for the parameter set for a task.
			 */
			ParameterSet(InMemoryXmlData  * fileInfo);

			/**
			 * Destructor
			 */
			virtual ~ParameterSet();

			/*************************** getters ***************************************/

			/**
			 * get an IntParam by name.
			 * @param paramName the name of the parameter desired.
             * @throw domain_error
			 */
			IntParam getIntParam(std::string paramName);

			/**
			 * get a double param by name.
			 * @param paramName the name of the parameter desired.
             * @throw domain_error
			 */
			DoubleParam getDoubleParam(std::string paramName);

			/**
			 * get a string param by name.
			 * @param paramName the name of the parameter desired.
             * @throw domain_error
			 */
			StringParam getStringParam(std::string paramName);

			/**
			 * get a bool param by name.
			 * @param paramName the name of the parameter desired.
             * @throw domain_error
			 */
			BoolParam  getBoolParam(std::string paramName);

			/**
			 * get an array of int params by name 
			 * @param paramName the name of the parameter desired.
             * @throw domain_error
			 */
			IntArrayParam getIntArrayParam(std::string paramName);

			/**
			 * get an array of double params by name
			 * @param paramName the name of the parameter desired.
             * @throw domain_error
			 */
			DoubleArrayParam getDoubleArrayParam(std::string paramName);

			/**
			 * get an array of string params by name
			 * @param paramName the name of the parameter desired.
             * @throw domain_error
			 */
			StringArrayParam getStringArrayParam(std::string paramName);

			/*************************** setters ***************************************/

			/**
			 * set an int param by name.
			 * @param paramName the name of the parameter to be set.
			 * @param value the value of the parameter.
			 */
			void setParam(std::string paramName, IntParam value);

			/**
			 * set a double param by name.
			 * @param paramName the name of the parameter to be set.
			 * @param value the value of the parameter.
			 */
			void setParam(std::string paramName, DoubleParam value);

			/**
			 * set a string param by name.
			 * @param paramName the name of the parameter to be set.
			 * @param value the value of the parameter.
			 */
			void setParam(std::string paramName, StringParam value);

			/**
			 * set a bool param by name.
			 * @param paramName the name of the parameter to be set.
			 * @param value the value of the parameter.
			 */
			void setParam(std::string paramName, BoolParam value);

			/**
			 * set an int array param by name.
			 * @param paramName the name of the parameter to be set.
			 * @param value the value of the parameter.
			 */
			void setParam(std::string paramName, IntArrayParam value);

			/**
			 * set a double array param by name.
			 * @param paramName the name of the parameter to be set.
			 * @param value the value of the parameter.
			 */
			void setParam(std::string paramName, DoubleArrayParam value);

			/**
			 * set a string array param by name.
			 * @param paramName the name of the parameter to be set.
			 * @param value the value of the parameter.
			 */
			void setParam(std::string paramName, StringArrayParam value);

			/**
			 * Returns the ParamSetDef, i.e. the parameter set definition for the ParameterSet. From
			 * the ParamSetDef, you can get things like the "help" and "prompt" text, etc.
			 */
			ParamSetDef* getParamSetDef();		

			/**
			 * Returns the name of the parameter set as a string.
			 */
			std::string getName();

			/**
			 * Converts the ParameterSet in-memory representation to an XML string.
			 */
			std::string toString();

		private:

			/**
			 * Sets the name for the parameter set.
			 */
			void setName(std::string psetName);

			/**
			 * Returns the file name for the psetdef associated with this ParameterSet,
			 * as defined by the <psetdef> tag in the ParameterSet XML instance document.
			 */
			std::string getParamSetDefFileName();

			/**
			 * Validates the parameter set
             * @throw invalid_argument
			 */
			void validate();

			/**
			 * Validates the bool params
             * @throw invalid_argument
			 */
			void validateBoolParams();
			/**
			 * Validates the bool parameters 
             * @throw invalid_argument
			 */
			void validateBoolParam(BoolParamDef pDef);

			/**
			 * Validates the int parameters 
             * @throw invalid_argument
			 */
			void validateIntParams();
			/**
			 * Validates the int parameters 
             * @throw invalid_argument
			 */
			void validateIntParam(IntParamDef pDef);

			/**
			 * Validates the double parameters 
             * @throw invalid_argument
			 */
			void validateDoubleParams();
			/**
			 * Validates the double parameters 
             * @throw invalid_argument
			 */
			void validateDoubleParam(DoubleParamDef pDef);

			/**
			 * Validates the string parameters 
             * @throw invalid_argument
			 */
			void validateStringParams();
			/**
			 * Validates the string parameters 
             * @throw invalid_argument
			 */
			void validateStringParam(StringParamDef pDef);

			/**
			 * Validates the int array parameters 
             * @throw invalid_argument
			 */
			void validateIntArrayParams();
			/**
			 * Validates the int array parameters 
             * @throw invalid_argument
			 */
			void validateIntArrayParam(IntArrayParamDef pDef);

			/**
			 * Validates the string array parameters 
             * @throw invalid_argument
			 */
			void validateStringArrayParams();
			/**
			 * Validates the string array parameters 
             * @throw invalid_argument
			 */
			void validateStringArrayParam(StringArrayParamDef pDef);

			/**
			 * Validates the double array parameters 
             * @throw invalid_argument
			 */
			void validateDoubleArrayParams();
			/**
			 * Validates the double array parameters 
             * @throw invalid_argument
			 */
			void validateDoubleArrayParam(DoubleArrayParamDef pDef);

            /**
             * @throw domain_error
             */
			int parseDOM(const char* xmlParamSet, InMemoryXmlData * fileInfo);
			int parseFile(const std::string & xmlFile);
			int parseSAX(const std::string & xmlParamSet);
            /**
             * @throw domain_error
             */
			void handleBoolParam(XERCES_CPP_NAMESPACE::DOMElement *paramElem);
            /**
             * @throw domain_error
             */
			void handleIntParam(XERCES_CPP_NAMESPACE::DOMElement *paramElem);
            /**
             * @throw domain_error
             */
			void handleIntArrayParam(XERCES_CPP_NAMESPACE::DOMElement *paramElem);
            /**
             * @throw domain_error
             */
			void handleDoubleParam(XERCES_CPP_NAMESPACE::DOMElement *paramElem);
            /**
             * @throw domain_error
             */
			void handleDoubleArrayParam(XERCES_CPP_NAMESPACE::DOMElement *paramElem);
            /**
             * @throw domain_error
             */
			void handleStringParam(XERCES_CPP_NAMESPACE::DOMElement *paramElem);
            /**
             * @throw domain_error
             */
			void handleStringArrayParam(XERCES_CPP_NAMESPACE::DOMElement *paramElem);
            /**
             * @throw domain_error
             */
			void processParamNodes(XERCES_CPP_NAMESPACE::DOMNodeList *paramNodes);
            /**
             * @throw domain_error
             */
			void initialize();
			void setSchemaLocation(XERCES_CPP_NAMESPACE::DOMLSParser * parser);

			std::string name;
			std::string psetDefFileName;
			std::map<std::string, IntParam> intParamMap;
			std::map<std::string, IntArrayParam> intArrayParamMap;
			std::map<std::string, DoubleParam> doubleParamMap;
			std::map<std::string, DoubleArrayParam> doubleArrayParamMap;
			std::map<std::string, StringParam> stringParamMap;
			std::map<std::string, StringArrayParam> stringArrayParamMap;
			std::map<std::string, BoolParam> boolParamMap;

			// Constants
			XMLCh* PSETDEF_TAG_NAME;
			XMLCh* PARAMETER_TAG_NAME;
			XMLCh* NAME_TAG_NAME;
			XMLCh* VALUE_TAG_NAME;
			XMLCh* UNITS_TAG_NAME;

			XMLCh* INT_PARAM_TYPE;
			XMLCh* DOUBLE_PARAM_TYPE;
			XMLCh* STRING_PARAM_TYPE;
			XMLCh* BOOL_PARAM_TYPE;
			XMLCh* INT_ARRAY_PARAM_TYPE;
			XMLCh* DOUBLE_ARRAY_PARAM_TYPE;
			XMLCh* STRING_ARRAY_PARAM_TYPE;

			std::shared_ptr<ParamSetDef> ParameterSetDef;
	};

}
#endif /*!_PARAMETER_SET_H*/

