#ifndef ACSSMARTPOINTER_H
#define ACSSMARTPOINTER_H
/*******************************************************************************
* ALMA - Atacama Large Millimiter Array
* (c) National Research Council of Canada, 2007
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
* "@(#) $Id: acsComponentSmartPtr.h,v 1.14 2010/07/17 20:43:02 agrimstrup Exp $"
*
* who       when      what
* --------  --------  ----------------------------------------------
* arne  2007-10-09  created
*/

/************************************************************************
 *
 *----------------------------------------------------------------------
 */

/* The following piece of code alternates the linkage type to C for all
functions declared within the braces, which is necessary to use the
functions in C++-code.
*/

#ifndef __cplusplus
#error This is a C++ include file and cannot be used from plain C
#endif

#include <logging.h>
#include <acsutilSmartPtr.h>
#include <maciErrType.h>
#include <ACSErrTypeCommon.h>

namespace maci {
    template <typename T>
    using SmartPtr = acsutil::SmartPtr<T>;

    class ContainerServices;

    template <typename T, typename H = ContainerServices>
    static void ContainerServicesDeleter(H* handle, bool sticky, T* pointee_) {
        if (handle && !CORBA::is_nil(pointee_) && sticky) {
            try {
                handle->releaseComponent(pointee_->name());
            } catch(maciErrType::CannotReleaseComponentExImpl& ex) {
                ACS_LOG(LM_RUNTIME_CONTEXT, "maci::ComponentStorage::Destroy", (LM_ERROR, "Unable to release component"));
            } catch(...) {
                ACS_LOG(LM_RUNTIME_CONTEXT, "maci::ComponentStorage::Destroy", (LM_ERROR, "Unexpected exception caught when releasing component."));
            }
        }
        if (!CORBA::is_nil(pointee_)) {
            CORBA::release(pointee_);
            pointee_ = T::_nil();
        }
    }

    template <typename T, typename H = ContainerServices>
    static SmartPtr<T> make_shared_component(H* handle = nullptr, bool sticky = false, T* ptr = nullptr) {
        if (!handle || CORBA::is_nil(ptr))
            throw ACSErrTypeCommon::IllegalArgumentExImpl(__FILE__, __LINE__, "maci::make_shared_component()");
        return SmartPtr<T>(ptr, [=](T*) {
            ContainerServicesDeleter(handle, sticky, ptr);
        });
    }
}

#endif /* ACSSMARTPOINTER_H */
