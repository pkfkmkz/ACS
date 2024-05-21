/*******************************************************************************
 * ALMA - Atacama Large Millimeter Array
 * Copyright (c) COSYLAB - Control System Laboratory, 2011
 * (in the framework of the ALMA collaboration).
 * All rights reserved.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
 *******************************************************************************/
/**
 * 
 */
package com.cosylab.cdb.jdal.hibernate;

import java.io.Serializable;

/**
 * Plain XML element with value.
 * @author msekoranja
 */
public class ElementValue implements ElementValueFeature, Serializable {

	/**
	 * Element value;
	 */
	private String _elementValue;
	
	/**
	 * Constructor.
	 */
	public ElementValue(String elementValue) {
		this._elementValue = elementValue;
	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.ElementValueFeature#getElementValue()
	 */
	public String getElementValue() {
		return _elementValue;
	}

	
}