package org.jacorb.poa.except;

/*
 *        JacORB - a free Java ORB
 *
 *   Copyright (C) 1997-2014 Gerald Brose / The JacORB Team.
 *
 *   This library is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU Library General Public
 *   License as published by the Free Software Foundation; either
 *   version 2 of the License, or (at your option) any later version.
 *
 *   This library is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *   Library General Public License for more details.
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this library; if not, write to the Free
 *   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */
 
/**
 * This exception will be thrown if the poa shutdown is in progress.
 * <p>
 * See also (private method) <code>org.jacorb.poa.RequestController.processRequest(org.jacorb.orb.dsi.ServerRequest)</code>.
 *
 * @author Reimo Tiedemann, FU Berlin
 * @version 1.0, 05/03/99, RT
 * @see     org.jacorb.poa.RequestController#run()
 * @see     org.jacorb.poa.POA#destroy(boolean, boolean)
 */
public final class ShutdownInProgressException
    extends java.lang.Exception 
{}






