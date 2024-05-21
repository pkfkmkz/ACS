/*
 *    ALMA - Atacama Large Millimiter Array
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
 *    Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
 *    MA 02111-1307  USA
 */
package com.cosylab.logging.engine;

/**
 * The interface for filterable objects
 * 
 * @author acaproni
 *
 */
public interface Filterable {
	/**
	 * 
	 * @return A vector of the filters in use 
	 */
	public FiltersVector getFilters();
	
	/**
	 * Set the filters.
	 * The new filters can replace or appended to the already exisiting filters.
	 * 
	 * The new filters can be <code>null</code> to remove the filtering. 
	 * For this purpose <code>append</code> must be <code>false</code>.
	 * 
	 * @param newFilters The new vector of filters
	 *                   It can be <code>null</code> to remove the filtering
	 * @param append If <code>true</code> the filters are appended to the existing filters
	 */
	public void setFilters(FiltersVector newFilters, boolean append);
	
}