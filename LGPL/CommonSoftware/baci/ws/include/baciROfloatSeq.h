#ifndef baciROfloatSeq_H
#define baciROfloatSeq_H

/*******************************************************************
* ALMA - Atacama Large Millimiter Array
* (c) European Southern Observatory, 2003 
*
*This library is free software; you can redistribute it and/or
*modify it under the terms of the GNU Lesser General Public
*License as published by the Free Software Foundation; either
*version 2.1 of the License, or (at your option) any later version.
*
*This library is distributed in the hope that it will be useful,
*but WITHOUT ANY WARRANTY; without even the implied warranty of
*MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*Lesser General Public License for more details.
*
*You should have received a copy of the GNU Lesser General Public
*License along with this library; if not, write to the Free Software
*Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*
* "@(#) $Id: baciROfloatSeq.h,v 1.3 2006/09/01 02:20:54 cparedes Exp $"
*
* who       when        what
* --------  ----------  ----------------------------------------------
* bjeram    2003/02/20 removed everything
* msekoran  2001/02/10  created
*/

/** 
 * @file 
 * Header file for BACI Read-only Float Sequence Property.
 */

#ifndef __cplusplus
#error This is a C++ include file and cannot be used from plain C
#endif

#include <baciMonitor_T.h>
#include <baciROSeqContImpl_T.h>


namespace baci {

/** @defgroup MonitorfloatSeqTemplate MonitorfloatSeq Class
 * The MonitorfloatSeq class is a templated typedef so there is no actual inline doc generated for it per-se.
 *  @{
 * The MonitorfloatSeq class is an implementation of the ACS::MonitorfloatSeq IDL interface.
 */
typedef  Monitor<ACS_MONITOR_SEQ(float, CORBA::Float)> MonitorfloatSeq;
/** @} */

/** @defgroup ROfloatSeqTemplate ROfloatSeq Class
 * The ROfloatSeq class is a templated typedef so there is no actual inline doc generated for it per-se.
 *  @{
 * The ROfloatSeq class is an implementation of the ACS::ROfloatSeq IDL interface.
 */
typedef  ROSeqContImpl<ACS_RO_SEQ_T(float, CORBA::Float)> ROfloatSeq;
/** @} */

 }

#endif  /* baciROfloatSeq */

