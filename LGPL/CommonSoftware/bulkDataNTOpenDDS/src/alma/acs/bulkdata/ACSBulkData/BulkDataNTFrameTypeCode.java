
/*
WARNING: THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.

This file was generated from .idl using "rtiddsgen".
The rtiddsgen tool is part of the RTI Connext distribution.
For more information, type 'rtiddsgen -help' at a command shell
or consult the RTI Connext manual.
*/

package alma.acs.bulkdata.ACSBulkData;

import com.rti.dds.typecode.*;

public class  BulkDataNTFrameTypeCode {
    public static final TypeCode VALUE = getTypeCode();

    private static TypeCode getTypeCode() {
        TypeCode tc = null;
        int __i=0;
        StructMember sm[]=new StructMember[3];
        Annotations memberAnnotation;

        memberAnnotation = new Annotations();
        memberAnnotation.default_annotation(AnnotationParameterValue.ZERO_ULONG);
        memberAnnotation.min_annotation(AnnotationParameterValue.MIN_ULONG);
        memberAnnotation.max_annotation(AnnotationParameterValue.MAX_ULONG);
        sm[__i] = new  StructMember("typeOfdata", false, (short)-1,  false, alma.acs.bulkdata.ACSBulkData.DataTypeTypeCode.VALUE, 0, false, memberAnnotation);__i++;
        memberAnnotation = new Annotations();
        memberAnnotation.default_annotation(AnnotationParameterValue.ZERO_ULONG);
        memberAnnotation.min_annotation(AnnotationParameterValue.MIN_ULONG);
        memberAnnotation.max_annotation(AnnotationParameterValue.MAX_ULONG);
        sm[__i] = new  StructMember("restDataLength", false, (short)-1,  false, TypeCode.TC_ULONG, 1, false, memberAnnotation);__i++;
        sm[__i] = new  StructMember("data", false, (short)-1,  false, new TypeCode((alma.acs.bulkdata.ACSBulkData.FRAME_MAX_LEN.VALUE), TypeCode.TC_OCTET), 2, false);__i++;

        Annotations annotation = new Annotations();
        annotation.allowed_data_representation_mask(5);

        tc = TypeCodeFactory.TheTypeCodeFactory.create_struct_tc("ACSBulkData::BulkDataNTFrame",ExtensibilityKind.EXTENSIBLE_EXTENSIBILITY,  sm , annotation);        
        return tc;
    }
}

