package alma.acs.cdb.rest.model;

import java.util.HashMap;

/**
 * Java class object representation of json thar rest api receives in order to write data to the CDB.
 */
public class CDBEntry {
    public String curl;
    public String node;
    public HashMap<String, String> properties;
    public CDBEntry[] subnodes;

    public CDBEntry(String curl, HashMap<String, String> properties){
        this.curl = curl;
        this.node = "";
        this.properties = properties;
        this.subnodes = new CDBEntry[0];
    }

    public CDBEntry(String curl, String node, HashMap<String, String> properties){
        this.curl = curl;
        this.node = node;
        this.properties = properties;
        this.subnodes = new CDBEntry[0];
    }


    public CDBEntry(String curl, HashMap<String, String> properties, CDBEntry[] subnodes){
        this.curl = curl;
        this.properties = properties;
        this.subnodes = subnodes;
    }

    public CDBEntry(){
        this.curl = "";
        this.properties = new HashMap<String, String>();
        this.subnodes = new CDBEntry[0];
    }

    public void setCurl(String curl){
        this.curl = curl;
    }

    public void setProperties(HashMap<String, String> properties) {
        this.properties = properties;
    }

    public void setSubnodes(CDBEntry[] subnodes) {
        this.subnodes = subnodes;
    }
    public String toString(){
        return "curl: " + this.curl + "\nproperties: " + this.properties.toString();
    }

    public boolean hasSubnodes(){
        if(this.subnodes == null || this.subnodes.length == 0)
            return false;
        
        return true;
    }
    
}
