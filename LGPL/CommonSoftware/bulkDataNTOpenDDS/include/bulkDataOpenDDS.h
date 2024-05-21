

/*
WARNING: THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.

This file was generated from bulkDataNT.idl using "rtiddsgen".
The rtiddsgen tool is part of the RTI Connext distribution.
For more information, type 'rtiddsgen -help' at a command shell
or consult the RTI Connext manual.
*/

#ifndef bulkDataNT_1411991815_h
#define bulkDataNT_1411991815_h

#ifndef NDDS_STANDALONE_TYPE
#ifndef ndds_cpp_h
#include "ndds/ndds_cpp.h"
#endif
#include "rti/xcdr/Interpreter.hpp"
#else
#include "ndds_standalone_type.h"
#endif

namespace ACSBulkData {

    typedef    DDS_UnsignedLong   DataType ;
    #if (defined(RTI_WIN32) || defined (RTI_WINCE) || defined(RTI_INTIME)) && defined(NDDS_USER_DLL_EXPORT)
    /* If the code is building on Windows, start exporting symbols.
    */
    #undef NDDSUSERDllExport
    #define NDDSUSERDllExport __declspec(dllexport)
    #endif

    #ifndef NDDS_STANDALONE_TYPE
    NDDSUSERDllExport DDS_TypeCode* DataType_get_typecode(void); /* Type code */
    NDDSUSERDllExport RTIXCdrTypePlugin *DataType_get_type_plugin_info(void);
    NDDSUSERDllExport RTIXCdrSampleAccessInfo *DataType_get_sample_access_info(void);
    NDDSUSERDllExport RTIXCdrSampleAccessInfo *DataType_get_sample_seq_access_info(void);
    #endif

    DDS_SEQUENCE(DataTypeSeq, DataType);

    NDDSUSERDllExport
    RTIBool DataType_initialize(
        DataType* self);

    NDDSUSERDllExport
    RTIBool DataType_initialize_ex(
        DataType* self,RTIBool allocatePointers,RTIBool allocateMemory);

    NDDSUSERDllExport
    RTIBool DataType_initialize_w_params(
        DataType* self,
        const struct DDS_TypeAllocationParams_t * allocParams);  

    NDDSUSERDllExport
    RTIBool DataType_finalize_w_return(
        DataType* self);

    NDDSUSERDllExport
    void DataType_finalize(
        DataType* self);

    NDDSUSERDllExport
    void DataType_finalize_ex(
        DataType* self,RTIBool deletePointers);

    NDDSUSERDllExport
    void DataType_finalize_w_params(
        DataType* self,
        const struct DDS_TypeDeallocationParams_t * deallocParams);

    NDDSUSERDllExport
    void DataType_finalize_optional_members(
        DataType* self, RTIBool deletePointers);  

    NDDSUSERDllExport
    RTIBool DataType_copy(
        DataType* dst,
        const DataType* src);

    #if (defined(RTI_WIN32) || defined (RTI_WINCE) || defined(RTI_INTIME)) && defined(NDDS_USER_DLL_EXPORT)
    /* If the code is building on Windows, stop exporting symbols.
    */
    #undef NDDSUSERDllExport
    #define NDDSUSERDllExport
    #endif

    static const DDS_UnsignedLong FRAME_MAX_LEN= 64000;

    static const DDS_UnsignedLong BD_PARAM= 0;

    static const DDS_UnsignedLong BD_DATA= 1;

    static const DDS_UnsignedLong BD_STOP= 2;

    static const DDS_UnsignedLong BD_RESET= 3;

    extern const char *BulkDataNTFrameTYPENAME;

    struct BulkDataNTFrameSeq;
    #ifndef NDDS_STANDALONE_TYPE
    class BulkDataNTFrameTypeSupport;
    class BulkDataNTFrameDataWriter;
    class BulkDataNTFrameDataReader;
    #endif
    class BulkDataNTFrame 
    {
      public:
        typedef struct BulkDataNTFrameSeq Seq;
        #ifndef NDDS_STANDALONE_TYPE
        typedef BulkDataNTFrameTypeSupport TypeSupport;
        typedef BulkDataNTFrameDataWriter DataWriter;
        typedef BulkDataNTFrameDataReader DataReader;
        #endif

        DDS_UnsignedLong   typeOfdata ;
        DDS_UnsignedLong   restDataLength ;
        DDS_OctetSeq  data ;

    };
    #if (defined(RTI_WIN32) || defined (RTI_WINCE) || defined(RTI_INTIME)) && defined(NDDS_USER_DLL_EXPORT)
    /* If the code is building on Windows, start exporting symbols.
    */
    #undef NDDSUSERDllExport
    #define NDDSUSERDllExport __declspec(dllexport)
    #endif

    #ifndef NDDS_STANDALONE_TYPE
    NDDSUSERDllExport DDS_TypeCode* BulkDataNTFrame_get_typecode(void); /* Type code */
    NDDSUSERDllExport RTIXCdrTypePlugin *BulkDataNTFrame_get_type_plugin_info(void);
    NDDSUSERDllExport RTIXCdrSampleAccessInfo *BulkDataNTFrame_get_sample_access_info(void);
    NDDSUSERDllExport RTIXCdrSampleAccessInfo *BulkDataNTFrame_get_sample_seq_access_info(void);
    #endif

    DDS_SEQUENCE(BulkDataNTFrameSeq, BulkDataNTFrame);

    NDDSUSERDllExport
    RTIBool BulkDataNTFrame_initialize(
        BulkDataNTFrame* self);

    NDDSUSERDllExport
    RTIBool BulkDataNTFrame_initialize_ex(
        BulkDataNTFrame* self,RTIBool allocatePointers,RTIBool allocateMemory);

    NDDSUSERDllExport
    RTIBool BulkDataNTFrame_initialize_w_params(
        BulkDataNTFrame* self,
        const struct DDS_TypeAllocationParams_t * allocParams);  

    NDDSUSERDllExport
    RTIBool BulkDataNTFrame_finalize_w_return(
        BulkDataNTFrame* self);

    NDDSUSERDllExport
    void BulkDataNTFrame_finalize(
        BulkDataNTFrame* self);

    NDDSUSERDllExport
    void BulkDataNTFrame_finalize_ex(
        BulkDataNTFrame* self,RTIBool deletePointers);

    NDDSUSERDllExport
    void BulkDataNTFrame_finalize_w_params(
        BulkDataNTFrame* self,
        const struct DDS_TypeDeallocationParams_t * deallocParams);

    NDDSUSERDllExport
    void BulkDataNTFrame_finalize_optional_members(
        BulkDataNTFrame* self, RTIBool deletePointers);  

    NDDSUSERDllExport
    RTIBool BulkDataNTFrame_copy(
        BulkDataNTFrame* dst,
        const BulkDataNTFrame* src);

    #if (defined(RTI_WIN32) || defined (RTI_WINCE) || defined(RTI_INTIME)) && defined(NDDS_USER_DLL_EXPORT)
    /* If the code is building on Windows, stop exporting symbols.
    */
    #undef NDDSUSERDllExport
    #define NDDSUSERDllExport
    #endif
} /* namespace ACSBulkData  */

#ifndef NDDS_STANDALONE_TYPE
namespace rti { 
    namespace xcdr {
        template <>
        struct type_code<ACSBulkData::BulkDataNTFrame> {
            static const RTIXCdrTypeCode * get();
        };

    } 
}

#endif

#endif /* bulkDataNT */

