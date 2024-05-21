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
package alma.tools.entitybuilder.jaxb;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.w3c.dom.Document;
import javax.xml.transform.dom.DOMResult;
import javax.xml.parsers.DocumentBuilderFactory;

import org.xml.sax.InputSource;
import javax.xml.namespace.QName;
import jakarta.xml.bind.Marshaller;
import jakarta.xml.bind.JAXBContext;
import jakarta.xml.bind.JAXBElement;
import jakarta.xml.bind.Unmarshaller;

import alma.tools.entitybuilder.BindingException;
import alma.tools.entitybuilder.jaxb.generated.EntitybuilderSettings;
import alma.tools.entitybuilder.jaxb.generated.EntitybuilderSettings.EntitySchema;
import alma.tools.entitybuilder.jaxb.generated.EntitybuilderSettings.XmlNamespace2JPackage;
import alma.tools.entitybuilder.jaxb.generated.bind.Bindings;
import alma.tools.entitybuilder.jaxb.generated.bind.Property;
import alma.tools.entitybuilder.jaxb.generated.bind.PackageType;
import alma.tools.entitybuilder.jaxb.generated.bind.SchemaBindings;
import alma.tools.entitybuilder.jaxb.generated.bind.GlobalBindings;


/**
 * @author hsommer
 */
public class EntitybuilderConfig {
    private EntitybuilderSettings m_entitybuilderSettings;

    /** key = schema file name w/o path, value = Java package */
    private Map<String, String> m_schema2pckMap = new HashMap<String, String>();

    /** key = xsd namespace, value = Java package */
    private Map<String, String> m_ns2pckMap = new HashMap<String, String>();

    private Map<String, File> m_schemaName2File = new HashMap<String, File>();
    private Map<String, String> m_schemaName2Namespace = new HashMap<String, String>();

    /**
     * Reads the configuration data.
     * @throws BindingException
     */
    public void load(File configFile, File[] includeConfigFiles) throws BindingException {
        m_entitybuilderSettings = parseConfigFile(configFile);
        storePckgMappings(m_entitybuilderSettings, configFile.getParentFile());

        for (File includeConfigFile : includeConfigFiles) {
            EntitybuilderSettings ebs = parseConfigFile(includeConfigFile);
            storePckgMappings(ebs, includeConfigFile.getParentFile());
        }
    }

    private void storePckgMappings(EntitybuilderSettings ebs, File schemaBaseDir) {
        for (XmlNamespace2JPackage mapping : ebs.getXmlNamespace2JPackages()) {
            String namespace = mapping.getXmlNamespace();
            String jPackage = mapping.getJPackage();
            m_ns2pckMap.put(namespace, jPackage);
        }

        for (EntitySchema schema : ebs.getEntitySchemas()) {
            String schemaName = schema.getSchemaName();
            String namespace = schema.getXmlNamespace();
            String jPackage = m_ns2pckMap.get(namespace);
            m_schema2pckMap.put(schemaName, jPackage);
            m_schemaName2Namespace.put(schemaName, namespace);

            String relPath = schema.getRelativePathSchemafile();
            if (relPath.trim().length() == 0 || relPath.equals(".")) {
                relPath = File.separator;
            } else {
                relPath = File.separator + relPath + File.separator;
            }
            String absPathName = schemaBaseDir.getAbsolutePath() + relPath + schema.getSchemaName();
            File schemaFile = new File(absPathName);
            if (schemaFile.exists()) {
                m_schemaName2File.put(schemaName, schemaFile);
            } else {
                System.err.println("specified schema file '" + absPathName + "' does not exist; will be ignored.");
            }
        }
    }

    /**
     * Gets all xsd namespaces, even those from included config files for which no code is generated directly.
     */
    public String[] getAllNamespaces() {
        return m_ns2pckMap.keySet().toArray(new String[1]);
    }

    public String getJPackageForNamespace(String ns) {
        String jPackage = m_ns2pckMap.get(ns);
        return jPackage;
    }

    /**
     * Gets all schema names, even those from included config files for which no code is generated directly.
     * Only file names, no directory path.
     */
    public String[] getAllSchemaNames() {
        return m_schema2pckMap.keySet().toArray(new String[1]);
    }

    public String getJPackageForSchema(String schemaName)  {
        String jPackage = m_schema2pckMap.get(schemaName);
        return jPackage;
    }

    /**
     * Gets all schema files which should be run explicitly through the code generator.
     * Schema files that are only used indirectly (include, import) are not returned.
     */
    public List<File> getPrimarySchemaFiles() throws BindingException {
        ArrayList<File> schemaList = new ArrayList<File>();
        for (EntitySchema schema : m_entitybuilderSettings.getEntitySchemas()) {
            File schemaFile = m_schemaName2File.get(schema.getSchemaName());
            if (schemaFile != null) {
                schemaList.add(schemaFile);
            }
            else {
                String msg = "specified schema file " + schema.getSchemaName() + " does not exist.";
                System.err.println(msg + " Will be ignored.");
                //throw new BindingException(msg; will be ignored.);
            }
        }
        return schemaList;
    }

    public List<File> getAllSchemaFiles() {
        return new ArrayList<File>(m_schemaName2File.values());
    }

    public Map<String, File> getSchemaName2File() {
        return Collections.unmodifiableMap(m_schemaName2File);
    }

    public Map<String, String> getSchemaName2Namespace() {
        return Collections.unmodifiableMap(m_schemaName2Namespace);
    }

    private EntitybuilderSettings parseConfigFile(File configFile) throws BindingException
    {
        EntitybuilderSettings ebs = null;
        InputStream is = null;

        try {
            is = new FileInputStream(configFile);
        } catch (Exception e) {
        }
        if (is == null) {
            throw new BindingException("xml config file '" + configFile.getAbsolutePath() + "' not found.");
        }
        try {
            ebs = (EntitybuilderSettings) JAXBContext.newInstance(EntitybuilderSettings.class).createUnmarshaller().unmarshal(new InputSource(is));
        } catch (Exception e) {
            String msg = "parsing of schema config file failed. ";
            throw new BindingException(msg, e);
        }
        return ebs;
    }

    public void writeXjb(File outputFile) throws BindingException {
        Bindings b = new Bindings();
        b.setVersion("3.0");
	b.addAttribute(new QName(null,"xmlns:xs"), "http://www.w3.org/2001/XMLSchema");
        GlobalBindings g = new GlobalBindings();
        QName qtag = new QName("http://java.sun.com/xml/ns/jaxb/xjc", "simple");
        JAXBElement jel = new JAXBElement(qtag, String.class, "");
        try {
            Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
            JAXBContext context = JAXBContext.newInstance(String.class);
            Marshaller marshaller = context.createMarshaller();
            marshaller.marshal(jel, new DOMResult(doc));
            g.setAny(doc.getDocumentElement());
        } catch (Exception e) {
            e.printStackTrace();
        }
        b.getGlobalBindingsAndSchemaBindingsAndClazzs().add(g);
        for (File schema : getPrimarySchemaFiles()) {
            Bindings sBind = new Bindings();
            sBind.setSchemaLocation("file:/" + schema.getName());
            //sBind.setNamespace(getSchemaName2Namespace().get(schema));
            SchemaBindings s = new SchemaBindings();
            PackageType p = new PackageType();
            p.getNames().add(getJPackageForSchema(schema.getName())+".jaxb");
            s.setPackage(p);
            sBind.getGlobalBindingsAndSchemaBindingsAndClazzs().add(s);
	    Bindings val = new Bindings();
	    val.setNode("//xs:extension[contains(@base, ':string')]/xs:attribute[@name='value']");
	    val.addAttribute(new QName(null, "required"), "false");
	    //val.addAttribute(new QName(null, "multiple"), "true");
	    Property prop = new Property();
	    prop.getNames().add("content");
	    val.getGlobalBindingsAndSchemaBindingsAndClazzs().add(prop);
	    sBind.getGlobalBindingsAndSchemaBindingsAndClazzs().add(val);
            b.getGlobalBindingsAndSchemaBindingsAndClazzs().add(sBind);
        }
        //System.out.println(b);
        try {
            Marshaller m = JAXBContext.newInstance(Bindings.class).createMarshaller();
            m.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);
            m.marshal(b, outputFile);
        } catch (Exception e) {
            String msg = "Problem writing the XML during marshalling.";
            throw new BindingException(msg, e);
        }
    }

//    private void generateXmlTemplate(File xmlFile) throws BindingException {
//        EntitybuilderSettings ebs = new EntitybuilderSettings();
//
//        EntitySchema es1 = new EntitySchema();
//        ebs.addEntitySchema(es1);
//        es1.setSchemaName("ObsProject.xsd");
//        es1.setXmlNamespace("Alma/ObsProject");
//
//        XmlNamespace2JPackage nsp = new XmlNamespace2JPackage();
//        ebs.addXmlNamespace2JPackage(nsp);
//        nsp.setXmlNamespace("Alma/ObsProject");
//        nsp.setJPackage("alma.entity.xmlbinding.obsproject");
//
//        try {
//            Marshaller.marshal(ebs, new FileWriter(xmlFile));
//        } catch (Exception e) {
//            throw new BindingException("marshalling error: ", e);
//        }
//    }
}
