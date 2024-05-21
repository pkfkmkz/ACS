package alma.acs.cdb.rest;

import java.net.InetAddress;
import java.util.logging.Logger;

import org.omg.CORBA.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;

import alma.acs.logging.AcsLogLevel;
import com.cosylab.cdb.jdal.XMLTreeNode;
import com.cosylab.cdb.jdal.XMLHandler;
import alma.acs.logging.ClientLogManager;
import alma.acs.cdb.rest.model.CDBEntry;
import alma.acs.util.ACSPorts;
import alma.cdbErrType.CDBRecordDoesNotExistEx;
import alma.cdbErrType.CDBXMLErrorEx;
import alma.cdbErrType.wrappers.AcsJCDBXMLErrorEx;
import alma.cdbErrType.wrappers.AcsJCDBRecordDoesNotExistEx;
import alma.cdbErrType.CDBXMLErrorEx;
import alma.cdbErrType.CDBRecordDoesNotExistEx;

import java.io.*;
import javax.xml.parsers.*;

import org.xml.sax.*;
import java.util.Iterator;


import java.util.HashMap;
import java.util.ArrayList;

@RestController
public class CDBAPIController {



    @GetMapping("/read/**")
    public ResponseEntity<HashMap<String, java.lang.Object>> read(HttpServletRequest request){

        String requestURL = request.getRequestURL().toString();
        String [] requestURLParts = requestURL.split("read/");

        if (requestURLParts.length < 2 || requestURLParts[1] == ""){
            HashMap<String, java.lang.Object> empty = new HashMap<String, java.lang.Object>();
            empty.put("error", "Empty CURL");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(empty);
        }

        String curl = requestURLParts[1];

        
        HashMap<String, java.lang.Object> cdbMap = CDBConnector.readCurlInCDB(curl, "corbaloc::10.197.52.10:3012/CDB");
        if(cdbMap == null || cdbMap.isEmpty()){
            HashMap<String, java.lang.Object> cdbEmptyMap = new HashMap<String, java.lang.Object>();
            cdbEmptyMap.put("error", "Record not found");
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(cdbEmptyMap);
        }

        return ResponseEntity.status(HttpStatus.OK)
                .contentType(MediaType.APPLICATION_JSON)
                .body(cdbMap);
        


    }

    @GetMapping("/list/**")
    public ResponseEntity<HashMap<String, java.lang.Object>> list(HttpServletRequest request){
        String requestURL = request.getRequestURL().toString();
        String [] requestURLParts = requestURL.split("list/");
        if (requestURLParts.length < 2 || requestURLParts[1] == ""){
            HashMap<String, java.lang.Object> emptyCurl = new HashMap<String, java.lang.Object>();
            emptyCurl.put("error", "Empty CURL");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(emptyCurl);
        }

        String curl = requestURLParts[1];

        String [] listNodes = CDBConnector.listNodes(curl, "corbaloc::10.197.52.10:3012/CDB");
        HashMap<String, java.lang.Object> response = new HashMap<String, java.lang.Object>();
        response.put("list", listNodes);
        return ResponseEntity.status(HttpStatus.OK)
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);

    }



    @PostMapping("/write")
    public ResponseEntity<HashMap<String, String>> write(@RequestBody final CDBEntry cdbEntry){
    // public String write(@RequestBody final CDBEntry cdbEntry){


        if(cdbEntry.curl == ""){
            HashMap<String, String> curlEmptyMap = new HashMap<String, String>();
            curlEmptyMap.put("error", "Empty CURL");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .contentType(MediaType.APPLICATION_JSON)
                .body(curlEmptyMap);
        }

        if(cdbEntry.properties.isEmpty()){
            HashMap<String, String> propertiesEmptyMap = new HashMap<String, String>();
            propertiesEmptyMap.put("error", "no properties");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .contentType(MediaType.APPLICATION_JSON)
                .body(propertiesEmptyMap);
        }

        HashMap<String, String> response = CDBConnector.writeCDBEntry(cdbEntry, "corbaloc::10.197.52.10:3012/CDB");

        if(response == null){
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .contentType(MediaType.APPLICATION_JSON)
            .body(response);
        }

        boolean success = ! response.keySet().contains("error");
        ResponseEntity<HashMap<String, String>> result = null;

        if(success){
            String typeOfWrite = response.get("INFO");
            if(typeOfWrite == "write"){
                result = ResponseEntity.status(HttpStatus.OK)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);

            }else if(typeOfWrite == "add"){
                result = ResponseEntity.status(HttpStatus.CREATED)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
            }
        }else{

            if(response.get("error") == "Record is read only"){
                result = ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .contentType(MediaType.APPLICATION_JSON)
                        .body(response);
            }else{
                result = ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
            }
        }
        if(result == null){
            result = ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .contentType(MediaType.APPLICATION_JSON)
            .body(response);
        }
        return result;

    }

    @DeleteMapping("/delete/**")
    public ResponseEntity<HashMap<String, String>>  delete(HttpServletRequest request){

        String requestURL = request.getRequestURL().toString();
        String [] requestURLParts = requestURL.split("delete/");
        if (requestURLParts.length < 2 || requestURLParts[1] == ""){
            HashMap<String, String> emptyCurl = new HashMap<String, String>();
            emptyCurl.put("error", "Empty CURL");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(emptyCurl);
        }

        String curl = requestURLParts[1];

        HashMap<String, String> response = CDBConnector.deleteNode(curl, "corbaloc::10.197.52.10:3012/CDB");
        
        boolean success = ! response.keySet().contains("error");

        ResponseEntity<HashMap<String, String>> result = null;

        if(success){
            result = ResponseEntity.status(HttpStatus.OK)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);

        }else{
            if(response.get("error") == "Record does not exist"){
                result = ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .contentType(MediaType.APPLICATION_JSON)
                        .body(response);
            }else if(response.get("error") == "Record is read only"){
                result = ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .contentType(MediaType.APPLICATION_JSON)
                        .body(response);
            }

        }
        if(result == null){
            result = ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }
        return result;


    }



}
