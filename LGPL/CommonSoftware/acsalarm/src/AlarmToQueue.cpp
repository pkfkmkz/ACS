/*******************************************************************************
* ALMA - Atacama Large Millimiter Array
* (c) European Southern Observatory, 2011 
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
* "@(#) $Id: AlarmToQueue.cpp,v 1.1 2011/06/22 20:56:15 acaproni Exp $"
*
* who       when      what
* --------  --------  ----------------------------------------------
* acaproni  2011-06-18  created
*/

#include "vltPort.h"

static const char *rcsId="@(#) $Id: AlarmToQueue.cpp,v 1.1 2011/06/22 20:56:15 acaproni Exp $"; 
static void *use_rcsId = ((void)&use_rcsId,(void *) &rcsId);

#include "AlarmToQueue.h"

using namespace acsalarm;

AlarmToQueue::AlarmToQueue(std::string fF, std::string fM, int fC, bool activestate):
		m_FF(fF),
		m_FM(fM),
		m_FC(fC),
		m_active(activestate)
{
}

AlarmToQueue::AlarmToQueue(std::string fF, std::string fM, int fC, Properties props, bool activestate):
		m_FF(fF),
		m_FM(fM),
		m_FC(fC),
		m_alarmProps(props),
		m_active(activestate)
{
}
/*___oOo___*/
