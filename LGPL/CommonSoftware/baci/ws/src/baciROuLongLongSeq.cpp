/*******************************************************************************
*    ALMA - Atacama Large Millimiter Array
*    (c) European Southern Observatory, 2002
*    Copyright by ESO (in the framework of the ALMA collaboration),
*    All rights reserved
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
*/

#include "baciROuLongLongSeq.h"
#include "baciAlarm_T.i"
#include "baciAlarmSystemMonitorSeqCont_T.i"
#include "baciROSeqContImpl_T.i"
#include "baciMonitor_T.i"

template class baci::Monitor<ACS_MONITOR_SEQ(uLongLong, ACS::uLongLong)>;

//we explicitly instantiate just two methods, otherwise (instantiation of whole class) we have problem with the constructor of ROcommonImpl
template void baci::ROcommonImpl<ACS_RO_SEQ_T(uLongLong, ACS::uLongLong)>::setAlarmFaultFamily(const char* ff);
template void baci::ROcommonImpl<ACS_RO_SEQ_T(uLongLong, ACS::uLongLong)>::setAlarmFaultMember(const char* fm);

template class baci::ROSeqContImpl<ACS_RO_SEQ_T(uLongLong, ACS::uLongLong)>;

/*___oOo___*/
