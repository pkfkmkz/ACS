/*
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
 *    Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
 *    MA 02111-1307  USA
 */
package alma.acs.entityutil;

import java.io.IOException;
import java.io.StringWriter;
import java.util.logging.Logger;

import org.exolab.castor.xml.Marshaller;

import alma.entities.commonentity.EntityT;
import alma.xmlentity.XmlEntityStruct;

/**
 * Serializes entity objects. 
 * These are instances of binding classes that represent the XML data in a type-safe Java API.
 * Currently all binding classes are generated using the Castor tool.
 * <p>
 * @author hsommer May 6, 2003 5:31:48 PM
 */
public class EntitySerializer
{
	private static EntitySerializer s_entitySerializer;
	private Logger m_logger;
	private boolean m_verbose;

	private XmlEntityStructFactory m_esf;

	private EntityTFinder m_finder;


	/**
	 * Singleton accessor.
	 * 
	 * @param logger Logger to be used 
	 * 			(may be null in subsequent invocations since only one instance of  
	 * 			 EntitySerializer is constructed and then reused)
	 *  
	 * @return single instance
	 */
	public static EntitySerializer getEntitySerializer(Logger logger)
	{
		if (s_entitySerializer == null)
		{
			s_entitySerializer = new EntitySerializer(logger);
		}
		return s_entitySerializer;
	}

	private EntitySerializer(Logger logger)
	{
		m_logger = logger;
		m_esf = new DefaultXmlEntityStructFactory();
		m_finder = new EntityTFinder(m_logger);
		setVerbose(false);
	}

	/**
	 * Makes this <code>EntitySerializer</code> use a client-supplied factory 
	 * for <code>XmlEntityStruct</code> objects.
	 * <p> 
	 * You should use this method if you wish to get a subclass of 
	 * <code>alma.xmlentity.XmlEntityStruct</code> returned from the 
	 * <code>serializeEntity</code> methods.
	 *  
	 * @param esf  the factory to be used
	 */
	public void setXmlEntityFactory(XmlEntityStructFactory esf)
	{
		m_esf = esf; 
	}
	
	
	/**
	 * Marshals an entity object to the CORBA struct used for transport.
	 * 
	 * @param entityObject  the entity object as a binding class, currently generated by castor.
	 * @param entityMeta  usually subtype of <code>EntityT</code>. 
	 * @return  the struct that contains the stringified xml and some other data;
	 * 			null if <code>entityObject</code> is null.
	 */
	public XmlEntityStruct serializeEntity(Object entityObject, EntityT entityMeta)
		throws EntityException
	{
		if (entityObject == null)
		{
			return null;
		}
		
		if (entityMeta == null)
		{
			throw new EntityException("Entity administrational data of type EntityT must not be null. " +
										"(object of type " + entityObject.getClass().getName() + ")");
		}
		
		XmlEntityStruct entStruct = m_esf.createXmlEntityStruct();
		try
		{
			entStruct.entityId = entityMeta.getEntityId();
			entStruct.entityTypeName = entityMeta.getEntityTypeName(); 
			entStruct.schemaVersion = ( entityMeta.getSchemaVersion() != null ? entityMeta.getSchemaVersion() : "");
			entStruct.timeStamp = ( entityMeta.getTimestamp() != null ? entityMeta.getTimestamp() : "");
			entStruct.xmlString = serializeEntityPart(entityObject);
		}
		catch (Exception e)
		{
			throw new EntityException(e);
		}
		return entStruct;
	}
	

	/**
	 * Marshals an entity object to the CORBA struct used for transport.
	 * Unlike in {@link #serializeEntity(Object, EntityT)}, the child of type
	 * <code>EntityT</code> that has the administrational information about the
	 * entity object, is not given as a parameter. 
	 * It will be accessed dynamically using {@link EntityTFinder}, which makes this
	 * method slightly slower than its 2-parameter companion.
	 * It's meant to be used rather by generic code that doesn't know about particular entity classes.
	 * 
	 * @param entityObject  the entity object as a binding class
	 * @return  the struct that contains the stringified xml and some other data;
	 * 			null if <code>entityObject</code> is null.
	 */
	public XmlEntityStruct serializeEntity(Object entityObject)
		throws EntityException
	{
		if (entityObject == null)
		{
			return null;
		}
		
		EntityT entityMeta = m_finder.extractEntityT(entityObject);

		return serializeEntity(entityObject, entityMeta);
	}
	
	
	/**
	 * Serializes a binding class object which is a part (child node) of some other full Entity object.
	 * @param entityPart the binding object, e.g. of type <code>alma.entity.xmlbinding.schedblock.CorrelatorConfigT</code>.
	 * @return a plain XML String that represents the data of <code>entityPart</code>.
	 * @throws EntityException if the operation could not be performed
	 * @see #serializeEntity(Object)
	 * @see #serializeEntity(Object, EntityT)
	 */
	public String serializeEntityPart(Object entityPart) throws EntityException {
		try {
            StringWriter wr = new StringWriter();
            Marshaller marsh = createMarshaller(wr);
            marsh.setValidation(false);
            marsh.marshal(entityPart);
            return wr.toString();
        } 
		catch (Exception e) {
			throw new EntityException("failed to serialize entity part of type '" + entityPart.getClass().getName() + "'.", e);
        }
	}

	protected Marshaller createMarshaller(StringWriter wr) throws IOException {
		return new Marshaller(wr);
	}
	
	public void setVerbose(boolean verbose)
	{
		m_verbose = verbose;
		m_finder.setVerbose(m_verbose);
	}
	
}