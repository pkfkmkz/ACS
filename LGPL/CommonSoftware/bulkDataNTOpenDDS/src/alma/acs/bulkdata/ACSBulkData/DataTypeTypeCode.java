
/*
WARNING: THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.

This file was generated from .idl using "rtiddsgen".
The rtiddsgen tool is part of the RTI Connext distribution.
For more information, type 'rtiddsgen -help' at a command shell
or consult the RTI Connext manual.
*/

package alma.acs.bulkdata.ACSBulkData;

import com.rti.dds.typecode.*;

public class  DataTypeTypeCode {
    public static final TypeCode VALUE = getTypeCode();

    private static TypeCode getTypeCode() {
        TypeCode tc = null;

        Annotations memberAnnotation;

        Annotations annotation = new Annotations();
        annotation.allowed_data_representation_mask(5);

        annotation.default_annotation(AnnotationParameterValue.ZERO_ULONG);
        annotation.min_annotation(AnnotationParameterValue.MIN_ULONG);
        annotation.max_annotation(AnnotationParameterValue.MAX_ULONG);
        tc = TypeCodeFactory.TheTypeCodeFactory.create_alias_tc("ACSBulkData::DataType", TypeCode.TC_ULONG,  false , annotation);        
        return tc;
    }
}

