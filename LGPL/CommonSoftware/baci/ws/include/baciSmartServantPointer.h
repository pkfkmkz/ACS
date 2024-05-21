#ifndef SMARTSERVANTPOINTER_H
#define SMARTSERVANTPOINTER_H
/*******************************************************************************
* ALMA - Atacama Large Millimiter Array
* (c) European Southern Observatory, 2004
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
* "@(#) $Id: baciSmartServantPointer.h,v 1.4 2005/01/07 23:41:17 dfugate Exp $"
*
* who       when      what
* --------  --------  ----------------------------------------------
* acaproni  2004-04-06  created
*/

/**
 * @file
 * Header file for BACI Smart Servant Pointers.
 */

#include <acsutilSmartPtr.h>

namespace baci
{

    /**
    * The smart pointer for a CORBA servant
    * Makes use of a custom deleter that ensures to call
    * the destroy method when the pointer is deleted
    *
    * @author <a href=mailto:acaproni@eso.org>Alessandro Caproni</a>
    */
    template<class T>
    using SmartServantPointer = acsutil::SmartPtr<T>;

    template <typename T>
    static void ServantDeleter(T* ptr) {
        if(ptr != 0) {
            ptr->destroy();
        }
    }

    template <typename T>
    static acsutil::SmartPtr<T> make_shared_servant(T* ptr = nullptr) {
        return acsutil::SmartPtr<T>(ptr, [=](T*) {
            ServantDeleter(ptr);
        });
    }

} // End of namespace baci

#include "baciSmartServantPointer.i"

#endif /*SMARTSERVANTPOINTER_H*/
