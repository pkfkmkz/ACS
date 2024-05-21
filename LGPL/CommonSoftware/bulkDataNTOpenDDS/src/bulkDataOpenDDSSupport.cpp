
/*
WARNING: THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.

This file was generated from bulkDataNT.idl using "rtiddsgen".
The rtiddsgen tool is part of the RTI Connext distribution.
For more information, type 'rtiddsgen -help' at a command shell
or consult the RTI Connext manual.
*/

#include "bulkDataOpenDDSSupport.h"
#include "bulkDataOpenDDSPlugin.h"

#ifndef dds_c_log_impl_h              
#include "dds_c/dds_c_log_impl.h"                                
#endif        

namespace ACSBulkData {

    /* ========================================================================= */
    /**
    <<IMPLEMENTATION>>

    Defines:   TData,
    TDataWriter,
    TDataReader,
    TTypeSupport

    Configure and implement 'BulkDataNTFrame' support classes.

    Note: Only the #defined classes get defined
    */

    /* ----------------------------------------------------------------- */
    /* DDSDataWriter
    */

    /**
    <<IMPLEMENTATION >>

    Defines:   TDataWriter, TData
    */

    /* Requires */
    #define TTYPENAME   BulkDataNTFrameTYPENAME

    /* Defines */
    #define TDataWriter BulkDataNTFrameDataWriter
    #define TData       ACSBulkData::BulkDataNTFrame

    #define ENABLE_TDATAWRITER_DATA_CONSTRUCTOR_METHODS
    #include "dds_cpp/generic/dds_cpp_data_TDataWriter.gen"
    #undef ENABLE_TDATAWRITER_DATA_CONSTRUCTOR_METHODS

    #undef TDataWriter
    #undef TData

    #undef TTYPENAME

    /* ----------------------------------------------------------------- */
    /* DDSDataReader
    */

    /**
    <<IMPLEMENTATION >>

    Defines:   TDataReader, TDataSeq, TData
    */

    /* Requires */
    #define TTYPENAME   BulkDataNTFrameTYPENAME

    /* Defines */
    #define TDataReader BulkDataNTFrameDataReader
    #define TDataSeq    BulkDataNTFrameSeq
    #define TData       ACSBulkData::BulkDataNTFrame

    #define ENABLE_TDATAREADER_DATA_CONSISTENCY_CHECK_METHOD
    #include "dds_cpp/generic/dds_cpp_data_TDataReader.gen"
    #undef ENABLE_TDATAREADER_DATA_CONSISTENCY_CHECK_METHOD

    #undef TDataReader
    #undef TDataSeq
    #undef TData

    #undef TTYPENAME

    /* ----------------------------------------------------------------- */
    /* TypeSupport

    <<IMPLEMENTATION >>

    Requires:  TTYPENAME,
    TPlugin_new
    TPlugin_delete
    Defines:   TTypeSupport, TData, TDataReader, TDataWriter
    */

    /* Requires */
    #define TTYPENAME    BulkDataNTFrameTYPENAME
    #define TPlugin_new  ACSBulkData::BulkDataNTFramePlugin_new
    #define TPlugin_delete  ACSBulkData::BulkDataNTFramePlugin_delete

    /* Defines */
    #define TTypeSupport BulkDataNTFrameTypeSupport
    #define TData        ACSBulkData::BulkDataNTFrame
    #define TDataReader  BulkDataNTFrameDataReader
    #define TDataWriter  BulkDataNTFrameDataWriter
    #define TGENERATE_SER_CODE
    #ifndef NDDS_STANDALONE_TYPE
    #define TGENERATE_TYPECODE
    #endif

    #include "dds_cpp/generic/dds_cpp_data_TTypeSupport.gen"

    #undef TTypeSupport
    #undef TData
    #undef TDataReader
    #undef TDataWriter
    #ifndef NDDS_STANDALONE_TYPE
    #undef TGENERATE_TYPECODE
    #endif
    #undef TGENERATE_SER_CODE
    #undef TTYPENAME
    #undef TPlugin_new
    #undef TPlugin_delete

} /* namespace ACSBulkData  */

