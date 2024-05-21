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
import java.io.FileWriter;
import java.io.IOException;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

import jakarta.xml.bind.Marshaller;
import jakarta.xml.bind.JAXBContext;
import org.xml.sax.SAXException;
import org.xml.sax.InputSource;
import org.xml.sax.EntityResolver;
import org.xml.sax.SAXParseException;

import com.sun.codemodel.JCodeModel;
import com.sun.tools.xjc.api.XJC;
import com.sun.tools.xjc.api.S2JJAXBModel;
import com.sun.tools.xjc.api.ErrorListener;
import com.sun.tools.xjc.api.SchemaCompiler;
import com.sun.tools.xjc.addon.episode.PluginImpl;

import alma.tools.entitybuilder.XsdFileFinder;
import alma.tools.entitybuilder.BindingException;
import alma.tools.entitybuilder.jaxb.EntitybuilderConfig;
import alma.tools.entitybuilder.jaxb.generated.catalog.Catalog;
import alma.tools.entitybuilder.jaxb.generated.catalog.ObjectFactory;

/**
 * Generates Java binding classes from xml schema files using the JAXB XJC generator framework.
 * Needs at least one configuration file for the mapping from xml namespaces to Java packages.
 */
public class XjcBuilder
{
    class AlmaEntityResolver implements EntityResolver {
        EntitybuilderConfig ebc = null;
        public AlmaEntityResolver(EntitybuilderConfig ebc) {
            this.ebc = ebc;
        }
        public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
            //if (true) throw new RuntimeException("Testing");
            // Grab only the filename part from the full path
            String schemaName = new File(systemId).getName();
            File schema = ebc.getSchemaName2File().get(schemaName);
            String ns = ebc.getSchemaName2Namespace().get(schemaName);
            InputSource is = null;
            if (schema != null) {
                is = new InputSource(new FileInputStream(schema.getAbsolutePath()));
                is.setSystemId(schema.toURI().normalize().toString());
                is.setSystemId("file:/" + schema.getName());
                is.setPublicId(ns);
            }
            return is;
        }
    }

    /** @param schemaDir (base) directory where the xsd files are, for which code will be generated. */
    File schemaDir;
    /** @param primaryConfigFile config file for the schema code generation. Currently must be in the directory <code>schemaDir</code>. */
    File primaryConfigFile;
    /* @param otherConfigFileNames Names without paths of schema code generation config files.
     *   While <code>primaryConfigFile</code> must contain the information for the schemas to compile directly,
     *   these config files have similar information for other schemas which are included by the "primary" schemas.
     *   This data is needed to generate correct Java packages of already existing binding classes. */
    ArrayList<String> otherConfigFileNames;
    /* @param includeDirs directories from which other xsd files or config files should be included,
     *   with preference to directories that appear first in case of multiple occurences of the same file. */
    ArrayList<File> includeDirs;
    /* @param javaOutputDir root directory under which the generated Java binding classes will be put */
    File javaOutputDir;

    /**
     * @param args <br>
     *   <code>args[0]</code>: xml config file (with path) complying to EntitybuilderSettings.xsd; for the schemas that need code generation; <br>
     *   <code>args[1]</code>: output directory under which the generated Java files will be put. <br>
     *   <code>args[2..n]</code>: -I schemaIncludeDirectory (optional)
     */
    public static void main(String[] args)
    {
        if (args.length < 2) {
            System.out.println("usage: java " + XjcBuilder.class.getName() + " configFile javaOutputDir [-I schemaIncludeDir]");
            System.exit(1);
        }

        try {
            String configFileConcat = System.getProperty("ACS.schemaconfigfiles");
            XjcBuilder builder = new XjcBuilder();
            builder.init(args, configFileConcat);
            builder.run();
        } catch (Exception ex) {
            System.err.println("schema compilation failed!");
            ex.printStackTrace(System.err);
            System.exit(1);
        }
    }

    /**
     * Parses the arguments given to <code>main</code> and then hands over control to method <code>run</code>.
     * @param args as in main
     * @param configFileConcat space-separated list of xsd binding config files for included schemas.
     * @throws BindingException
     * @throws FileNotFoundException
     */
    public void init(String[] args, String configFileConcat) throws BindingException, FileNotFoundException
    {
        // the xml config file that knows the schemas that should be compiled,
        // as well as namespace and java package info.
        primaryConfigFile = new File(args[0]);

        // the directory with the schemas that should be compiled
        schemaDir = primaryConfigFile.getParentFile();

        // the root directory for Java class output
        javaOutputDir = new File(args[1]);

        // -- config files for included schemas
        otherConfigFileNames = new ArrayList<String>();
        if (configFileConcat != null) {
            StringTokenizer includeSchemasConfigFilesTok = new StringTokenizer(configFileConcat, " ");
            while (includeSchemasConfigFilesTok.hasMoreTokens()) {
                String configFileName = includeSchemasConfigFilesTok.nextToken().trim();
                if (configFileName.length() > 0) {
                    if (!configFileName.endsWith(".xml")) {
                        configFileName += ".xml";
                    }
                    otherConfigFileNames.add(configFileName);
                }
            }
        }

        // include directories (both schema files and config files)
        includeDirs = new ArrayList<File>();
        boolean pendingInclude = false;
        for (int argInd = 2; argInd < args.length; argInd++) {
            String arg = args[argInd].trim();
            arg = (arg.charAt(0) == '"' ? arg.substring(1) : arg);
            arg = (arg.charAt(arg.length()-1) == '"' ? arg.substring(0, arg.length()-1) : arg);
            if (pendingInclude) {
                includeDirs.add(new File(arg));
                pendingInclude = false;
            } else if (arg.startsWith("-I")) {
                if (arg.length() == 2) {
                    // just -I, no path
                    pendingInclude = true;
                } else {
                    // "-I/a/b/dir" or "-I /a/b/dir" is given as one option
                    includeDirs.add(new File(arg.substring(2)));
                    pendingInclude = false;
                }
            }
        }
    }

    /**
     * Runs the Castor code generator.
     * @throws BindingException
     * @throws FileNotFoundException
     */
    public void run() throws BindingException, FileNotFoundException {
        // the xml config file that knows the schemas that should be compiled
        if (!primaryConfigFile.exists()) {
            throw new FileNotFoundException("invalid configuration file: " + primaryConfigFile.getAbsolutePath());
        }
        List<String> allConfigFileNames = new ArrayList<String>();
        allConfigFileNames.add(primaryConfigFile.getName());
        allConfigFileNames.addAll(otherConfigFileNames);

        List<File> allIncludeDirs = new ArrayList<File>();
        // the ALMA Makefile explicitly lists the local schema directory as an include dir,
        // but it does not hurt to try adding it anyway
        allIncludeDirs.add(schemaDir);
        // in some cases the schema dir may be different from the primary config file's directory.
        // Thus we add the latter explicity, because otherwise the config file would no longer be found.
        allIncludeDirs.add(primaryConfigFile.getParentFile());
        // and of course we must add the explicitly given include dirs
        allIncludeDirs.addAll(includeDirs);

        if (!javaOutputDir.exists()) {
            System.out.println("will create output directory " + javaOutputDir.getAbsolutePath());
        }

        XsdFileFinder xsdFileFinder = new XsdFileFinder(allIncludeDirs, allConfigFileNames);
        xsdFileFinder.setVerbose(false);

        EntitybuilderConfig ebc = new EntitybuilderConfig();
        ebc.load(primaryConfigFile, xsdFileFinder.getAllXsdConfigFiles());

        File xjb = new File(primaryConfigFile.getAbsolutePath().replace(".xml", ".xjb"));
        ebc.writeXjb(xjb);

        SchemaCompiler sc = XJC.createSchemaCompiler();
        AlmaEntityResolver almaEntityResolver = new AlmaEntityResolver(ebc);
        sc.setEntityResolver(almaEntityResolver);
        sc.setErrorListener(new ErrorListener(){
            public void error(SAXParseException ex){
                ex.printStackTrace();
            }
            public void fatalError(SAXParseException ex){
                ex.printStackTrace();
            }
            public void warning(SAXParseException ex){
                ex.printStackTrace();
            }
            public void info(SAXParseException ex){
                ex.printStackTrace();
            }
        });
        sc.getOptions().packageLevelAnnotations = false;
        sc.getOptions().compatibilityMode = sc.getOptions().EXTENSION;
        sc.getOptions().addBindFile(new File(primaryConfigFile.getAbsolutePath().replace(".xml", ".xjb")));
        for (File config : xsdFileFinder.getAllXsdConfigFiles()) {
            if (config.getName().equals(primaryConfigFile.getName())) continue;
            File episode = new File(config.getAbsolutePath().replace(".xml", ".episode"));
            if (episode.exists() && episode.isFile()) {
                sc.getOptions().addBindFile(episode);
            }
        }

        try {
            File cat = new File(primaryConfigFile.getAbsolutePath().replace(".xml", ".cat"));
            Catalog c = new Catalog();
            for (File schemaFile : ebc.getAllSchemaFiles()) {
                alma.tools.entitybuilder.jaxb.generated.catalog.System s = new alma.tools.entitybuilder.jaxb.generated.catalog.System();
                s.setSystemId(schemaFile.getName());
                s.setUri(schemaFile.getAbsolutePath());
                c.getPublicsAndSystemsAndUris().add(s);
                s = new alma.tools.entitybuilder.jaxb.generated.catalog.System();
                s.setSystemId("file:/" + schemaFile.getName());
                s.setUri(schemaFile.getAbsolutePath());
                c.getPublicsAndSystemsAndUris().add(s);
                s = new alma.tools.entitybuilder.jaxb.generated.catalog.System();
                s.setSystemId("file:" + new File(System.getProperty("user.dir")).getAbsolutePath() + "/" + schemaFile.getName());
                s.setUri(schemaFile.getAbsolutePath());
                c.getPublicsAndSystemsAndUris().add(s);
                s = new alma.tools.entitybuilder.jaxb.generated.catalog.System();
                s.setSystemId("file:" + new File(System.getProperty("user.dir")).getParentFile().getAbsolutePath() + "/idl/" + schemaFile.getName());
                s.setUri(schemaFile.getAbsolutePath());
                c.getPublicsAndSystemsAndUris().add(s);
                s = new alma.tools.entitybuilder.jaxb.generated.catalog.System();
                s.setSystemId("file:" + schemaFile.getAbsolutePath());
                s.setUri(schemaFile.getAbsolutePath());
                c.getPublicsAndSystemsAndUris().add(s);
                String intlist = System.getenv("INTLIST");
                if (intlist != null) {
                    for (String introot: intlist.split(":")) {
                        s = new alma.tools.entitybuilder.jaxb.generated.catalog.System();
                        s.setSystemId("file:" + new File(introot).getAbsolutePath() + "/idl/" + schemaFile.getName());
                        s.setUri(schemaFile.getAbsolutePath());
                        c.getPublicsAndSystemsAndUris().add(s);
                    }
                }
                String introot = System.getenv("INTROOT");
                if (introot != null) {
                    s = new alma.tools.entitybuilder.jaxb.generated.catalog.System();
                    s.setSystemId("file:" + new File(introot).getAbsolutePath() + "/idl/" + schemaFile.getName());
                    s.setUri(schemaFile.getAbsolutePath());
                    c.getPublicsAndSystemsAndUris().add(s);
                }
            }
            Marshaller m = JAXBContext.newInstance(Catalog.class).createMarshaller();
            m.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);
            m.marshal(c, cat);
        } catch (Throwable th) {
            th.printStackTrace();
        }

        PluginImpl plugin = new PluginImpl();
        sc.getOptions().getAllPlugins().add(plugin);
        try {
            sc.getOptions().parseArgument(new String[] {"-" + plugin.getOptionName(), primaryConfigFile.getAbsolutePath().replace(".xml", ".episode")}, 0);
            sc.getOptions().parseArgument(new String[] {"-catalog", primaryConfigFile.getAbsolutePath().replace(".xml", ".cat")}, 0);
        } catch (Throwable th) {
            th.printStackTrace();
        }
        sc.setEntityResolver(sc.getOptions().entityResolver);

        for (File schemaFile : ebc.getAllSchemaFiles()) {
            if (!(schemaFile.exists() && schemaFile.isFile())) {
                throw new FileNotFoundException("unable to open XML schema file " + schemaFile.getAbsolutePath());
            }
            String schemaPackage = ebc.getJPackageForSchema(schemaFile.getName());
            System.out.println("\n-- generating classes for " + schemaFile.getAbsolutePath() + " into " + schemaPackage + " --");
            InputSource is = new InputSource(new FileInputStream(schemaFile));
            //is.setSystemId(schemaFile.toURI().normalize().toString());
            is.setSystemId("file:/" + schemaFile.getName());
            is.setPublicId(ebc.getSchemaName2Namespace().get(schemaFile.getName()));
            sc.parseSchema(is);
        }
        generate(sc, javaOutputDir);
        System.out.println("schema compile done!\n");
    }

    private void generate(SchemaCompiler sc, File outputDir) throws FileNotFoundException {
        S2JJAXBModel model = sc.bind();
        JCodeModel jmodel = model.generateCode(null, null);
        try {
            jmodel.build(outputDir);
        } catch (Throwable th) {
            th.printStackTrace();
        }
    }
}
