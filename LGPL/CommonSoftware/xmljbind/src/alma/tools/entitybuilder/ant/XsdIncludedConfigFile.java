/*
 *    ALMA - Atacama Large Millimiter Array
 *    (c) European Southern Observatory, 2004
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
 *    Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 *    MA 02111-1307  USA
 */
package alma.tools.entitybuilder.ant;


/**
 * @author hsommer
 * created Aug 18, 2004 5:05:14 PM
 */
public class XsdIncludedConfigFile {
    /** just the name of the config file, w/o path */
    private String filename;

    public void setFilename(String newFilename) {
        filename = newFilename;
    }

    public String getFilename() {
        return filename;
    }
}
