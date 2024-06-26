/*******************************************************************************
* ALMA - Atacama Large Millimiter Array
* (c) UNSPECIFIED - FILL IN, 2005 
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
* "@(#) $Id: loggingGetLogger.cpp,v 1.3 2007/03/04 17:40:31 msekoran Exp $"
*
* who       when      what
* --------  --------  ----------------------------------------------
* dfugate  2005-08-03  created 
*/

/************************************************************************
*   NAME
*   
* 
*   SYNOPSIS
*   
* 
*   DESCRIPTION
*
*   FILES
*
*   ENVIRONMENT
*
*   COMMANDS
*
*   RETURN VALUES
*
*   CAUTIONS 
*
*   EXAMPLES
*
*   SEE ALSO
*
*   BUGS   
* 
*------------------------------------------------------------------------
*/

#include "loggingGetLogger.h"

static const char *rcsId="@(#) $Id: loggingGetLogger.cpp,v 1.3 2007/03/04 17:40:31 msekoran Exp $"; 
static void *use_rcsId = ((void)&use_rcsId,(void *) &rcsId);

//---------------------------------------------------------------------------------------
Logging::Logger::LoggerSmartPtr
getLogger()
{   
    return Logging::Logger::getGlobalLogger();
}
//---------------------------------------------------------------------------------------
Logging::Logger::LoggerSmartPtr
getNamedLogger(const std::string& loggerName)
{
    // just delegate to getLogger function (really the global logger)
    return getLogger()->getLogger(loggerName);
}
//---------------------------------------------------------------------------------------
