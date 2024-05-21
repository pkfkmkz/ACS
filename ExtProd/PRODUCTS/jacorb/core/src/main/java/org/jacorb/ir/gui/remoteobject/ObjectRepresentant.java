/*
 *        JacORB - a free Java ORB
 *
 *   Copyright (C) 1999-2014 Gerald Brose / The JacORB Team.
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
 *
 */
package org.jacorb.ir.gui.remoteobject;

import javax.swing.tree.TreeModel;
import org.jacorb.ir.gui.typesystem.ModelBuilder;
import org.jacorb.ir.gui.typesystem.ModelParticipant;
import org.jacorb.ir.gui.typesystem.TypeSystemNode;

/**
 * This class was generated by a SmartGuide.
 *
 */

public class ObjectRepresentant extends ModelParticipant
{
    protected Object counterPart;
    // there could be real remote objects and local objects in it
    protected String name;
    protected TypeSystemNode typeSystemNode;

    /**
     * This method was created by a SmartGuide.
     * @param counterPart java.lang.Object
     */
    protected ObjectRepresentant (Object counterPart, TypeSystemNode type, String name) {
    this.counterPart = counterPart;
    if (name!=null) {
            setName(name);
    }
    else {
            setName("this");
    }
    typeSystemNode = type;
    System.out.println(this+" value: "+value());
    }
    /**
     * This method was created by a SmartGuide.
     * @return int
     * @param other org.jacorb.ir;.gui.typesystem.ModelParticipant
     */
    public int compareTo(ModelParticipant other) {
    return this.toString().compareTo(other.toString());
    }
    /**
     * This method was created by a SmartGuide.
     * @return TreeModel
     */
    public TreeModel getTreeModel() {
    return ModelBuilder.getSingleton().buildTreeModelAsync(this);
    }
    /**
     * This method was created by a SmartGuide.
     * @return org.jacorb.ir;.gui.typesystem.TypeSystemNode
     */
    public TypeSystemNode getTypeSystemNode() {
    return typeSystemNode;
    }
    /**
     * This method was created by a SmartGuide.
     * @param name java.lang.String
     */
    protected void setName(String name) {
    this.name = name;
    }
    /**
     * This method was created by a SmartGuide.
     * @return java.lang.String
     */
    public String toString() {
	if (typeSystemNode!=null) { // could be null, e.g. with PIDLs
            return typeSystemNode.getAbsoluteName() + " " + name;
    }
    else {
            return name;
    }
    }
    /**
     * This method was created by a SmartGuide.
     * @return java.lang.String
     */
    public String value() {
    if (counterPart!=null) {
            return counterPart.toString();
    }
    else {
            return "nil";
    }
    }
}
