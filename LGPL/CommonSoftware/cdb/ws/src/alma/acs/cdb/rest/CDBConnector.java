package alma.acs.cdb.rest;

import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.Set;

import java.util.logging.Logger;

import org.omg.CORBA.*;

import com.cosylab.CDB.*;

import alma.acs.logging.AcsLogLevel;
import com.cosylab.cdb.jdal.XMLTreeNode;
import com.cosylab.cdb.jdal.XMLHandler;
import alma.acs.logging.ClientLogManager;
import alma.acs.cdb.rest.model.CDBEntry;
import alma.acs.util.ACSPorts;
import alma.cdbErrType.CDBRecordDoesNotExistEx;
import alma.cdbErrType.CDBRecordIsReadOnlyEx;
import alma.cdbErrType.CDBRecordAlreadyExistsEx;
import alma.cdbErrType.CDBXMLErrorEx;
import alma.cdbErrType.CDBExceptionEx;
import alma.cdbErrType.CDBFieldDoesNotExistEx;
import alma.cdbErrType.CDBFieldIsReadOnlyEx;
import alma.cdbErrType.wrappers.AcsJCDBXMLErrorEx;
import alma.cdbErrType.wrappers.AcsJCDBRecordDoesNotExistEx;
import alma.cdbErrType.wrappers.AcsJCDBRecordAlreadyExistsEx;
import alma.cdbErrType.wrappers.AcsJCDBRecordIsReadOnlyEx;
import alma.cdbErrType.wrappers.AcsJCDBExceptionEx;
import alma.cdbErrType.CDBXMLErrorEx;
import alma.cdbErrType.CDBRecordDoesNotExistEx;

import java.io.*;
import java.net.InetAddress;
import javax.xml.parsers.*;

import org.xml.sax.*;
import java.util.Iterator;

public class CDBConnector {

    private static Logger m_logger = ClientLogManager.getAcsLogManager().getLoggerForApplication("CDBConnector", false);

    private static HashMap<String, java.lang.Object> xmlToMap(XMLTreeNode node) {

        HashMap<String, java.lang.Object> nodeMap = new HashMap<String, java.lang.Object>();
        Iterator<String> iterator = node.getFieldMap().keySet().iterator();

        if (iterator.hasNext()) {
            nodeMap.put("Node", node.getName());
            while (iterator.hasNext()) {
                String key = iterator.next();
                String value = node.getFieldMap().get(key);
                nodeMap.put(key, value);
            }
        }

        Iterator nodesIter = node.getNodesMap().keySet().iterator();

        if (nodesIter.hasNext()) {
            ArrayList<java.lang.Object> subNodesMap = new ArrayList<java.lang.Object>();
            while (nodesIter.hasNext()) {
                String key = (String) nodesIter.next();
                XMLTreeNode value = (XMLTreeNode) node.getNodesMap().get(key);
                subNodesMap.add(xmlToMap(value));
            }
            nodeMap.put("subnodes", subNodesMap);
        }

        return nodeMap;
    }

    private static String cdbEntryToXml(CDBEntry cdbEntry) {

        String node;
        if(cdbEntry.node == ""){
            String[] curlArray = cdbEntry.curl.split("/");
            node = curlArray[curlArray.length-1];
        }else{
            node = cdbEntry.node;
        }


        String properties = "";
        for (Map.Entry<String, String> set : cdbEntry.properties.entrySet()) {

            String field = set.getKey();
            String value = set.getValue();
            properties = properties + " " + field + "=\"" + value + "\"";

        }

        

        String subnodes = "";
        if(cdbEntry.hasSubnodes()){
            
            for(int i=0; i< cdbEntry.subnodes.length; i++){
                 subnodes = subnodes + cdbEntryToXml(cdbEntry.subnodes[i]);
            }

        }
        

        String xmlCdbEntry = "<" + node + 
                                properties + 
                                ">" +
                                subnodes + 
                                "</" + node + ">";

        return xmlCdbEntry;

    }

    public static HashMap<String, java.lang.Object> readCurlInCDB(String curl, String strIOR) {

        try {

            if (strIOR == null) {
                strIOR = "corbaloc::" + InetAddress.getLocalHost().getHostName() + ":" + ACSPorts.getCDBPort() + "/CDB";
            }

            ORB orb = ORB.init(new String[0], null);

            DAL dal = DALHelper.narrow(orb.string_to_object(strIOR));

            String xml = dal.get_DAO(curl);

            SAXParserFactory factory = SAXParserFactory.newInstance();
            SAXParser saxParser = factory.newSAXParser();
            XMLHandler xmlSolver = new XMLHandler(false, m_logger);
            saxParser.parse(new InputSource(new StringReader(xml)), xmlSolver);
            if (xmlSolver.m_errorString != null) {
                m_logger.log(AcsLogLevel.ERROR, "XML parser error: " + xmlSolver.m_errorString);
                CDBXMLErrorEx xmlErr = new CDBXMLErrorEx();
                throw xmlErr;
            }

            m_logger.log(AcsLogLevel.INFO, "Query to CDB was successful, formatting JSON equivalent to " + curl);

            HashMap<String, java.lang.Object> resultQuery = xmlToMap(xmlSolver.m_rootNode);

            return resultQuery;

        } catch (CDBXMLErrorEx e) {
            AcsJCDBXMLErrorEx je = AcsJCDBXMLErrorEx.fromCDBXMLErrorEx(e);
            String smsg = "XML Error \tCURL='" + je.getCurl() + "'\n\t\tFilename='" + je.getFilename()
                    + "'\n\t\tNodename='" + je.getNodename() + "'\n\t\tMSG='" + je.getErrorString() + "'";
            smsg += "\n CDBXMLErrorEx: " + e.getMessage();

            m_logger.log(AcsLogLevel.NOTICE, smsg, je);
            return new HashMap<String, java.lang.Object>();
        } catch (CDBRecordDoesNotExistEx e) {
            AcsJCDBRecordDoesNotExistEx je = AcsJCDBRecordDoesNotExistEx.fromCDBRecordDoesNotExistEx(e);
            String smsg = "Record does not exist \tCURL='" + je.getCurl() + "'";
            m_logger.log(AcsLogLevel.NOTICE, smsg, je);
            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static HashMap<String, String> writeCDBEntry(CDBEntry cdbEntry, String strIOR) {
        HashMap<String, String> writeResult = new HashMap<String, String>();

        if (cdbEntry.properties.isEmpty()) {

            m_logger.log(AcsLogLevel.ERROR, "CDB entry has no properties to change. Returning");
            writeResult.put("error", "No properties in given CDB entry");
            return writeResult;
        }

        String curl = cdbEntry.curl;

        if(curl==null || curl ==""){
            m_logger.log(AcsLogLevel.ERROR, "CDB entry has no given CURL. Returning");
            writeResult.put("error", "CURL is empty");
            return writeResult;
        }
        try {

            ORB orb = ORB.init(new String[0], null);

            WDAL wdal = WDALHelper.narrow(orb.string_to_object(strIOR));

            WDAO wdao = wdal.get_WDAO_Servant(curl);

            for (Map.Entry<String, String> set : cdbEntry.properties.entrySet()) {

                String field = set.getKey();
                String value = set.getValue();

                try{

                    wdao.set_string(field, value);
                    writeResult.put(field, "success");

                }catch(CDBFieldDoesNotExistEx e){
                    writeResult.put(field, "ERROR: Field does not exist");
                }catch(CDBFieldIsReadOnlyEx e){
                    writeResult.put(field, "ERROR: Field is read only");
                }

            }

            clearCache(strIOR, orb);
            writeResult.put("INFO", "write");
            m_logger.log(AcsLogLevel.INFO, "Write to " + cdbEntry.curl + " finished");
            return writeResult;

        }
        catch (CDBRecordDoesNotExistEx e){
            m_logger.log(AcsLogLevel.INFO, "Record for curl " + cdbEntry.curl + "does not exist. Adding new entry");
            writeResult.clear();
            boolean added = writeNewCDBEntry(cdbEntry, strIOR);
            if(added){
                writeResult.put("message", "New CDB entry added");
            }else{
                writeResult.put("error", "New CDB entry could not be added");
            }
            writeResult.put("INFO", "add");
            m_logger.log(AcsLogLevel.INFO, "New CDB entry " + cdbEntry.curl + " added");
            return writeResult;
        }catch(CDBRecordIsReadOnlyEx e){
            AcsJCDBRecordIsReadOnlyEx je = AcsJCDBRecordIsReadOnlyEx.fromCDBRecordIsReadOnlyEx(e);
            String smsg = "Record is read only \tCURL='" + je.getCurl() + "'";
            m_logger.log(AcsLogLevel.ERROR, smsg);
            writeResult.clear();
            writeResult.put("error", "Record is read only");
            return writeResult;
        }

        catch (CDBXMLErrorEx e) {
            AcsJCDBXMLErrorEx e2 = new AcsJCDBXMLErrorEx(e);
            System.out.println("XMLerror : " + e2.getCurl());
            e.printStackTrace(System.out);
            writeResult.put("error", "There was an XMLerror during writting process");
            return writeResult;
        }

        catch (Exception e) {
            System.out.println("ERROR : " + e);
            e.printStackTrace(System.out);
            writeResult.put("error", "internal server error");
            return writeResult;
        }
    }
    public static boolean writeNewCDBEntry(CDBEntry cdbEntry, String strIOR){
        String xml = cdbEntryToXml(cdbEntry);

        if(xml.equals("")){
            return false;
        }

        try {
            
            ORB orb = ORB.init(new String[0], null);

            WDAL wdal = WDALHelper.narrow(orb.string_to_object(strIOR));

            wdal.add_node(cdbEntry.curl, xml);

            clearCache(strIOR, orb);
            return true;

        }catch(CDBRecordAlreadyExistsEx e){
            AcsJCDBRecordAlreadyExistsEx e2 = new AcsJCDBRecordAlreadyExistsEx(e);
            System.out.println("CDBRecordAlreadyExistsError : " + e2.getCurl());
            return false;  
        } catch (CDBXMLErrorEx e) {
            AcsJCDBXMLErrorEx e2 = new AcsJCDBXMLErrorEx(e);
            System.out.println("XMLerror : " + e2.getCurl());
            e.printStackTrace(System.out);
            return false;
        }catch(CDBExceptionEx e){
            e.printStackTrace(System.out);
            return false;
        }

        catch (Exception e) {
            System.out.println("ERROR : " + e);
            e.printStackTrace(System.out);
            return false;
        }

    }


    public static String[] listNodes(String curl, String strIOR) {

        try {

            if (strIOR == null) {
                strIOR = "corbaloc::" + InetAddress.getLocalHost().getHostName() + ":" + ACSPorts.getCDBPort() + "/CDB";
            }

            ORB orb = ORB.init(new String[0], null);

            DAL dal = DALHelper.narrow(orb.string_to_object(strIOR));

            String stringList = dal.list_nodes(curl);
            

            String[] list = stringList.split(" ");

            if(list.length == 0 || (list.length == 1 && list[0] == "")){
                
                String xml = dal.get_DAO(curl);

                SAXParserFactory factory = SAXParserFactory.newInstance();
                SAXParser saxParser = factory.newSAXParser();
                XMLHandler xmlSolver = new XMLHandler(false, m_logger);
                saxParser.parse(new InputSource(new StringReader(xml)), xmlSolver);
                if (xmlSolver.m_errorString != null) {
                    m_logger.log(AcsLogLevel.ERROR, "XML parser error: " + xmlSolver.m_errorString);
                    CDBXMLErrorEx xmlErr = new CDBXMLErrorEx();
                    throw xmlErr;
                }

                m_logger.log(AcsLogLevel.INFO, "Query to CDB was successful, formatting list equivalent to " + curl);

                HashMap<String, java.lang.Object> resultQuery = xmlToMap(xmlSolver.m_rootNode);
                ArrayList<HashMap<java.lang.Object, java.lang.Object>> subnodes = (ArrayList<HashMap<java.lang.Object, java.lang.Object>>) resultQuery.get("subnodes");
                String [] listKeys = new String[subnodes.size()];
                
                for(int i=0; i<subnodes.size(); i++){
                    listKeys[i] = subnodes.get(i).get("Node").toString();
                }
                return listKeys;

            }else{
                return list;
            }
            
        } catch (Exception e) {
            m_logger.log(AcsLogLevel.NOTICE, "ERROR : " + e);
            e.printStackTrace(System.out);
            return null;
        }
    }

    public static HashMap<String, String> deleteNode(String curl, String strIOR){
        HashMap<String, String> returnValue = new HashMap<String, String>();
        returnValue.put("curl", curl);
        try {

            if (strIOR == null) {
                // use default
                strIOR = "corbaloc::" + InetAddress.getLocalHost().getHostName() + ":" + ACSPorts.getCDBPort() + "/CDB";
            }


            
            ORB orb = ORB.init(new String[0], null);

            WDAL wdal = WDALHelper.narrow(orb.string_to_object(strIOR));

            wdal.remove_node(curl);
            
            clearCache(strIOR, orb);

            
            returnValue.put("success", "CDB entry deleted");
            return returnValue;

        }
        catch(CDBRecordDoesNotExistEx e){
            AcsJCDBRecordDoesNotExistEx je = AcsJCDBRecordDoesNotExistEx.fromCDBRecordDoesNotExistEx(e);
            String smsg = "Record does not exist \tCURL='" + je.getCurl() + "'";
            m_logger.log(AcsLogLevel.NOTICE, smsg, je);
            
            // return new HashMap<String, java.lang.Object>();
            returnValue.put("error", "Record does not exist");
            return returnValue;
        }catch(CDBRecordIsReadOnlyEx e){
            AcsJCDBRecordIsReadOnlyEx je = AcsJCDBRecordIsReadOnlyEx.fromCDBRecordIsReadOnlyEx(e);
            String smsg = "Record is read only \tCURL='" + je.getCurl() + "'";
            m_logger.log(AcsLogLevel.ERROR, smsg, je);
            returnValue.put("error", "Record is read only");
            return returnValue;
        }

        catch (Exception e) {
            System.out.println("ERROR : " + e);
            e.printStackTrace(System.out);
            returnValue.put("error", "Internal server error");
            return returnValue;
        }
    }

    private static void clearCache(String strIOR, ORB orb){
        JDAL dal = JDALHelper.narrow(orb.string_to_object(strIOR));
        dal.clear_cache_all();
    }

}
