/*
 * ALMA - Atacama Large Millimeter Array
 * (c) European Southern Observatory, 2002
 * (c) Associated Universities Inc., 2002
 * Copyright by ESO (in the framework of the ALMA collaboration),
 * Copyright by AUI (in the framework of the ALMA collaboration),
 * All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY, without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307  USA
 *
 * "@(#) $Id: StringEnumUserType.java,v 1.1 2011/05/13 17:40:37 rtobar Exp $"
 */
package alma.hibernate.util;

import java.io.Serializable;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

import org.hibernate.Hibernate;
import org.hibernate.HibernateException;
import org.hibernate.type.StandardBasicTypes;
import org.hibernate.usertype.EnhancedUserType;
import org.hibernate.usertype.ParameterizedType;
import org.hibernate.internal.util.ReflectHelper;
import org.hibernate.engine.spi.SharedSessionContractImplementor;

/**
 * Custom mapping type for string-backed enumerations.
 *
 * Taken from "Java Persistence with Hibernate", Christian Bauer and
 * Gavin King, Manning, ISBN 1-932394-88-5.
 *
 * This class was initially used by the handwritten ICD/SharedCode/Persistence
 * TMCDB domain classes. It has been moved down to ACS to be used also by the
 * generated TMCDB pojos.
 */
@SuppressWarnings("unchecked")
public class StringEnumUserType implements EnhancedUserType<Enum>, ParameterizedType {

	private Class<Enum> enumClass;

    public void setParameterValues(Properties parameters) {
        String enumClassName =
            parameters.getProperty("enumClassName");
        try {
            enumClass = ReflectHelper.classForName(enumClassName);
            try {
				enumClass.getMethod("valueOfForEnum", String.class);
			} catch (SecurityException e) {
			} catch (NoSuchMethodException e) {
				throw new HibernateException("Class '" + enumClass.getCanonicalName() + "' does not implement the valueOfForEnum(String), cannot proceed");
			}
        } catch (ClassNotFoundException cnfe) {
            throw new HibernateException("Enum class not found", cnfe);
        }
    }

    public Class<Enum> returnedClass() {
        return enumClass;
    }

    public int getSqlType() {
        return StandardBasicTypes.STRING.getSqlTypeCode();
    }

    public boolean isMutable() {
        return false;
    }

    public Enum deepCopy(Enum value) throws HibernateException {
        return value;
    }

    public Serializable disassemble(Enum value) throws HibernateException {
        return (Serializable) value;
    }

    public Enum assemble(Serializable cached, Object owner)
            throws HibernateException {
        return (Enum)cached;
    }

    public Enum replace(Enum original, Enum target, Object owner)
            throws HibernateException {
        return original;
    }

    public boolean equals(Enum x, Enum y) throws HibernateException {
        if (x == y)
            return true;
        if (x == null || y == null)
            return false;
        return x.equals(y);
    }

    public int hashCode(Enum x) throws HibernateException {
        return x.hashCode();
    }

    public Enum fromStringValue(CharSequence xmlValue) {
        try {
			return (Enum) enumClass.getMethod("valueOfForEnum", String.class).invoke(enumClass, xmlValue);
		} catch (Exception e) {
			e.printStackTrace();
			throw new HibernateException("Cannot invoke valueOfForEnum(String) in class '" + enumClass.getCanonicalName() + "'");
		}
    }

    public String toSqlLiteral(Enum value) {
        return '\'' + value.toString() + '\'';
    }

    public String toString(Enum value) {
        return value.toString();
    }

    @Override
    public Enum nullSafeGet(ResultSet rs, int position, SharedSessionContractImplementor si, Object owner)
            throws HibernateException, SQLException {
        String name = rs.getString(position);
        try {
			return rs.wasNull() ? null : 
				(Enum) enumClass.getMethod("valueOfForEnum", String.class).invoke(enumClass, name);
		} catch (Exception e) {
			throw new HibernateException("Cannot invoke valueOfForEnum(String) in class '" + enumClass.getCanonicalName() + "'");
		}
    }

    @Override
    public void nullSafeSet(PreparedStatement st, Enum value, int index, SharedSessionContractImplementor si)
            throws HibernateException, SQLException {
        if (value == null) {
            st.setNull(index, StandardBasicTypes.STRING.getSqlTypeCode());
        } else {
            st.setString(index, value.toString()); // Enum.toString() must be overriden by enumClass
        }
    }
}
