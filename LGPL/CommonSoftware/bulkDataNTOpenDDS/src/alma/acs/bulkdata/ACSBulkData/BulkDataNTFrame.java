

/*
WARNING: THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.

This file was generated from .idl using "rtiddsgen".
The rtiddsgen tool is part of the RTI Connext distribution.
For more information, type 'rtiddsgen -help' at a command shell
or consult the RTI Connext manual.
*/

package alma.acs.bulkdata.ACSBulkData;

import com.rti.dds.infrastructure.*;
import com.rti.dds.infrastructure.Copyable;
import java.io.Serializable;
import com.rti.dds.cdr.CdrHelper;

public class BulkDataNTFrame   implements Copyable, Serializable{

    public int typeOfdata = (int)0;
    public int restDataLength = (int)0;
    public ByteSeq data =  new ByteSeq((alma.acs.bulkdata.ACSBulkData.FRAME_MAX_LEN.VALUE));

    public BulkDataNTFrame() {

    }
    public BulkDataNTFrame (BulkDataNTFrame other) {

        this();
        copy_from(other);
    }

    public static Object create() {

        BulkDataNTFrame self;
        self = new  BulkDataNTFrame();
        self.clear();
        return self;

    }

    public void clear() {

        typeOfdata = (int)0;
        restDataLength = (int)0;
        if (data != null) {
            data.clear();
        }
    }

    public boolean equals(Object o) {

        if (o == null) {
            return false;
        }        

        if(getClass() != o.getClass()) {
            return false;
        }

        BulkDataNTFrame otherObj = (BulkDataNTFrame)o;

        if(typeOfdata != otherObj.typeOfdata) {
            return false;
        }
        if(restDataLength != otherObj.restDataLength) {
            return false;
        }
        if(!data.equals(otherObj.data)) {
            return false;
        }

        return true;
    }

    public int hashCode() {
        int __result = 0;
        __result += (int)typeOfdata;
        __result += (int)restDataLength;
        __result += data.hashCode(); 
        return __result;
    }

    /**
    * This is the implementation of the <code>Copyable</code> interface.
    * This method will perform a deep copy of <code>src</code>
    * This method could be placed into <code>BulkDataNTFrameTypeSupport</code>
    * rather than here by using the <code>-noCopyable</code> option
    * to rtiddsgen.
    * 
    * @param src The Object which contains the data to be copied.
    * @return Returns <code>this</code>.
    * @exception NullPointerException If <code>src</code> is null.
    * @exception ClassCastException If <code>src</code> is not the 
    * same type as <code>this</code>.
    * @see com.rti.dds.infrastructure.Copyable#copy_from(java.lang.Object)
    */
    public Object copy_from(Object src) {

        BulkDataNTFrame typedSrc = (BulkDataNTFrame) src;
        BulkDataNTFrame typedDst = this;

        typedDst.typeOfdata = typedSrc.typeOfdata;
        typedDst.restDataLength = typedSrc.restDataLength;
        typedDst.data.copy_from(typedSrc.data);

        return this;
    }

    public String toString(){
        return toString("", 0);
    }

    public String toString(String desc, int indent) {
        StringBuffer strBuffer = new StringBuffer();        

        if (desc != null) {
            CdrHelper.printIndent(strBuffer, indent);
            strBuffer.append(desc).append(":\n");
        }

        CdrHelper.printIndent(strBuffer, indent+1);        
        strBuffer.append("typeOfdata: ").append(typeOfdata).append("\n");  
        CdrHelper.printIndent(strBuffer, indent+1);        
        strBuffer.append("restDataLength: ").append(restDataLength).append("\n");  
        CdrHelper.printIndent(strBuffer, indent+1);
        strBuffer.append("data: ");
        for(int i__ = 0; i__ < data.size(); ++i__) {
            if (i__!=0) strBuffer.append(", ");
            strBuffer.append(data.get(i__));
        }
        strBuffer.append("\n"); 

        return strBuffer.toString();
    }

}
