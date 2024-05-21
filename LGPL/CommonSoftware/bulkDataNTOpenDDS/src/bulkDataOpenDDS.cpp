

/*
WARNING: THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.

This file was generated from bulkDataNT.idl using "rtiddsgen".
The rtiddsgen tool is part of the RTI Connext distribution.
For more information, type 'rtiddsgen -help' at a command shell
or consult the RTI Connext manual.
*/

#ifndef NDDS_STANDALONE_TYPE
#ifndef ndds_cpp_h
#include "ndds/ndds_cpp.h"
#endif
#ifndef dds_c_log_impl_h              
#include "dds_c/dds_c_log_impl.h"                                
#endif 
#ifndef dds_c_log_infrastructure_h                      
#include "dds_c/dds_c_infrastructure_impl.h"       
#endif 

#ifndef cdr_type_h
#include "cdr/cdr_type.h"
#endif    

#ifndef osapi_heap_h
#include "osapi/osapi_heap.h" 
#endif
#else
#include "ndds_standalone_type.h"
#endif

#include "bulkDataOpenDDS.h"

#ifndef NDDS_STANDALONE_TYPE
#include "bulkDataOpenDDSPlugin.h"
#endif

#include <new>

namespace ACSBulkData {

    /* ========================================================================= */

    #ifndef NDDS_STANDALONE_TYPE
    DDS_TypeCode* DataType_get_typecode()
    {
        static RTIBool is_initialized = RTI_FALSE;

        static DDS_TypeCode DataType_g_tc =
        {{
                DDS_TK_ALIAS, /* Kind*/
                DDS_BOOLEAN_FALSE,/* Is a pointer? */
                -1, /* Ignored */
                (char *)"ACSBulkData::DataType", /* Name */
                NULL, /* Content type code is assigned later */
                0, /* Ignored */
                0, /* Ignored */
                NULL, /* Ignored */
                0, /* Ignored */
                NULL, /* Ignored */
                DDS_VM_NONE, /* Ignored */
                RTICdrTypeCodeAnnotations_INITIALIZER,
                DDS_BOOLEAN_TRUE, /* _isCopyable */
                NULL, /* _sampleAccessInfo: assigned later */
                NULL /* _typePlugin: assigned later */
            }}; /* Type code for  DataType */

        if (is_initialized) {
            return &DataType_g_tc;
        }

        DataType_g_tc._data._annotations._allowedDataRepresentationMask = 5;

        DataType_g_tc._data._typeCode =  (RTICdrTypeCode *)&DDS_g_tc_ulong_w_new;

        /* Initialize the values for member annotations. */
        DataType_g_tc._data._annotations._defaultValue._d = RTI_XCDR_TK_ULONG;
        DataType_g_tc._data._annotations._defaultValue._u.ulong_value = 0u;
        DataType_g_tc._data._annotations._minValue._d = RTI_XCDR_TK_ULONG;
        DataType_g_tc._data._annotations._minValue._u.ulong_value = RTIXCdrUnsignedLong_MIN;
        DataType_g_tc._data._annotations._maxValue._d = RTI_XCDR_TK_ULONG;
        DataType_g_tc._data._annotations._maxValue._u.ulong_value = RTIXCdrUnsignedLong_MAX;

        DataType_g_tc._data._sampleAccessInfo =
        DataType_get_sample_access_info();
        DataType_g_tc._data._typePlugin =
        DataType_get_type_plugin_info();    

        is_initialized = RTI_TRUE;

        return &DataType_g_tc;
    }

    #define TSeq DataTypeSeq
    #define T DataType
    #include "dds_cpp/generic/dds_cpp_data_TInterpreterSupport.gen"
    #undef T
    #undef TSeq

    RTIXCdrSampleAccessInfo *DataType_get_sample_seq_access_info()
    {
        static RTIXCdrSampleAccessInfo DataType_g_seqSampleAccessInfo = {
            RTI_XCDR_TYPE_BINDING_CPP, \
            {sizeof(DataTypeSeq),0,0,0}, \
            RTI_XCDR_FALSE, \
            DDS_Sequence_get_member_value_pointer, \
            DataTypeSeq_set_member_element_count, \
            NULL, \
            NULL, \
            NULL \
        };

        return &DataType_g_seqSampleAccessInfo;
    }

    RTIXCdrSampleAccessInfo *DataType_get_sample_access_info()
    {
        static RTIBool is_initialized = RTI_FALSE;

        static RTIXCdrMemberAccessInfo DataType_g_memberAccessInfos[1] =
        {RTIXCdrMemberAccessInfo_INITIALIZER};

        static RTIXCdrSampleAccessInfo DataType_g_sampleAccessInfo = 
        RTIXCdrSampleAccessInfo_INITIALIZER;

        if (is_initialized) {
            return (RTIXCdrSampleAccessInfo*) &DataType_g_sampleAccessInfo;
        }

        DataType_g_memberAccessInfos[0].bindingMemberValueOffset[0] = 0;

        DataType_g_sampleAccessInfo.memberAccessInfos = 
        DataType_g_memberAccessInfos;

        {
            size_t candidateTypeSize = sizeof(DataType);

            if (candidateTypeSize > RTIXCdrUnsignedLong_MAX) {
                DataType_g_sampleAccessInfo.typeSize[0] =
                RTIXCdrUnsignedLong_MAX;
            } else {
                DataType_g_sampleAccessInfo.typeSize[0] =
                (RTIXCdrUnsignedLong) candidateTypeSize;
            }
        }

        DataType_g_sampleAccessInfo.useGetMemberValueOnlyWithRef =
        RTI_XCDR_TRUE;

        DataType_g_sampleAccessInfo.getMemberValuePointerFcn = 
        DataType_get_member_value_pointer;

        DataType_g_sampleAccessInfo.languageBinding = 
        RTI_XCDR_TYPE_BINDING_CPP ;

        is_initialized = RTI_TRUE;
        return (RTIXCdrSampleAccessInfo*) &DataType_g_sampleAccessInfo;
    }

    RTIXCdrTypePlugin *DataType_get_type_plugin_info()
    {
        static RTIXCdrTypePlugin DataType_g_typePlugin = 
        {
            NULL, /* serialize */
            NULL, /* serialize_key */
            NULL, /* deserialize_sample */
            NULL, /* deserialize_key_sample */
            NULL, /* skip */
            NULL, /* get_serialized_sample_size */
            NULL, /* get_serialized_sample_max_size_ex */
            NULL, /* get_serialized_key_max_size_ex */
            NULL, /* get_serialized_sample_min_size */
            NULL, /* serialized_sample_to_key */
            (RTIXCdrTypePluginInitializeSampleFunction) 
            ACSBulkData::DataType_initialize_ex,
            NULL,
            (RTIXCdrTypePluginFinalizeSampleFunction)
            ACSBulkData::DataType_finalize_w_return,
            NULL
        };

        return &DataType_g_typePlugin;
    }
    #endif

    RTIBool DataType_initialize(
        DataType* sample) {
        return ACSBulkData::DataType_initialize_ex(sample,RTI_TRUE,RTI_TRUE);
    }

    RTIBool DataType_initialize_ex(
        DataType* sample,RTIBool allocatePointers, RTIBool allocateMemory)
    {

        struct DDS_TypeAllocationParams_t allocParams =
        DDS_TYPE_ALLOCATION_PARAMS_DEFAULT;

        allocParams.allocate_pointers =  (DDS_Boolean)allocatePointers;
        allocParams.allocate_memory = (DDS_Boolean)allocateMemory;

        return ACSBulkData::DataType_initialize_w_params(
            sample,&allocParams);

    }

    RTIBool DataType_initialize_w_params(
        DataType* sample, const struct DDS_TypeAllocationParams_t * allocParams)
    {

        if (sample == NULL) {
            return RTI_FALSE;
        }
        if (allocParams == NULL) {
            return RTI_FALSE;
        }

        (*sample) = 0u;

        return RTI_TRUE;
    }

    RTIBool DataType_finalize_w_return(
        DataType* sample)
    {
        ACSBulkData::DataType_finalize_ex(sample, RTI_TRUE);

        return RTI_TRUE;
    }

    void DataType_finalize(
        DataType* sample)
    {

        ACSBulkData::DataType_finalize_ex(sample,RTI_TRUE);
    }

    void DataType_finalize_ex(
        DataType* sample,RTIBool deletePointers)
    {
        struct DDS_TypeDeallocationParams_t deallocParams =
        DDS_TYPE_DEALLOCATION_PARAMS_DEFAULT;

        if (sample==NULL) {
            return;
        } 

        deallocParams.delete_pointers = (DDS_Boolean)deletePointers;

        ACSBulkData::DataType_finalize_w_params(
            sample,&deallocParams);
    }

    void DataType_finalize_w_params(
        DataType* sample,const struct DDS_TypeDeallocationParams_t * deallocParams)
    {

        if (sample==NULL) {
            return;
        }

        if (deallocParams == NULL) {
            return;
        }

    }

    void DataType_finalize_optional_members(
        DataType* sample, RTIBool deletePointers)
    {
        struct DDS_TypeDeallocationParams_t deallocParamsTmp =
        DDS_TYPE_DEALLOCATION_PARAMS_DEFAULT;
        struct DDS_TypeDeallocationParams_t * deallocParams =
        &deallocParamsTmp;

        if (sample==NULL) {
            return;
        } 
        if (deallocParams) {} /* To avoid warnings */

        deallocParamsTmp.delete_pointers = (DDS_Boolean)deletePointers;
        deallocParamsTmp.delete_optional_members = DDS_BOOLEAN_TRUE;

    }

    RTIBool DataType_copy(
        DataType* dst,
        const DataType* src)
    {
        try {

            if (dst == NULL || src == NULL) {
                return RTI_FALSE;
            }

            if (!RTICdrType_copyUnsignedLong (
                dst, src)) { 
                return RTI_FALSE;
            }

            return RTI_TRUE;

        } catch (const std::bad_alloc&) {
            return RTI_FALSE;
        }
    }

    /**
    * <<IMPLEMENTATION>>
    *
    * Defines:  TSeq, T
    *
    * Configure and implement 'DataType' sequence class.
    */
    #define T DataType
    #define TSeq DataTypeSeq

    #define T_initialize_w_params ACSBulkData::DataType_initialize_w_params

    #define T_finalize_w_params   ACSBulkData::DataType_finalize_w_params
    #define T_copy       ACSBulkData::DataType_copy

    #ifndef NDDS_STANDALONE_TYPE
    #include "dds_c/generic/dds_c_sequence_TSeq.gen"
    #include "dds_cpp/generic/dds_cpp_sequence_TSeq.gen"
    #else
    #include "dds_c_sequence_TSeq.gen"
    #include "dds_cpp_sequence_TSeq.gen"
    #endif

    #undef T_copy
    #undef T_finalize_w_params

    #undef T_initialize_w_params

    #undef TSeq
    #undef T

    /* ========================================================================= */
    const char *BulkDataNTFrameTYPENAME = "ACSBulkData::BulkDataNTFrame";

    #ifndef NDDS_STANDALONE_TYPE
    DDS_TypeCode* BulkDataNTFrame_get_typecode()
    {
        static RTIBool is_initialized = RTI_FALSE;

        static DDS_TypeCode BulkDataNTFrame_g_tc_data_sequence = DDS_INITIALIZE_SEQUENCE_TYPECODE(((ACSBulkData::FRAME_MAX_LEN)),NULL);

        static DDS_TypeCode_Member BulkDataNTFrame_g_tc_members[3]=
        {

            {
                (char *)"typeOfdata",/* Member name */
                {
                    0,/* Representation ID */
                    DDS_BOOLEAN_FALSE,/* Is a pointer? */
                    -1, /* Bitfield bits */
                    NULL/* Member type code is assigned later */
                },
                0, /* Ignored */
                0, /* Ignored */
                0, /* Ignored */
                NULL, /* Ignored */
                RTI_CDR_REQUIRED_MEMBER, /* Is a key? */
                DDS_PUBLIC_MEMBER,/* Member visibility */
                1,
                NULL, /* Ignored */
                RTICdrTypeCodeAnnotations_INITIALIZER
            }, 
            {
                (char *)"restDataLength",/* Member name */
                {
                    1,/* Representation ID */
                    DDS_BOOLEAN_FALSE,/* Is a pointer? */
                    -1, /* Bitfield bits */
                    NULL/* Member type code is assigned later */
                },
                0, /* Ignored */
                0, /* Ignored */
                0, /* Ignored */
                NULL, /* Ignored */
                RTI_CDR_REQUIRED_MEMBER, /* Is a key? */
                DDS_PUBLIC_MEMBER,/* Member visibility */
                1,
                NULL, /* Ignored */
                RTICdrTypeCodeAnnotations_INITIALIZER
            }, 
            {
                (char *)"data",/* Member name */
                {
                    2,/* Representation ID */
                    DDS_BOOLEAN_FALSE,/* Is a pointer? */
                    -1, /* Bitfield bits */
                    NULL/* Member type code is assigned later */
                },
                0, /* Ignored */
                0, /* Ignored */
                0, /* Ignored */
                NULL, /* Ignored */
                RTI_CDR_REQUIRED_MEMBER, /* Is a key? */
                DDS_PUBLIC_MEMBER,/* Member visibility */
                1,
                NULL, /* Ignored */
                RTICdrTypeCodeAnnotations_INITIALIZER
            }
        };

        static DDS_TypeCode BulkDataNTFrame_g_tc =
        {{
                DDS_TK_STRUCT, /* Kind */
                DDS_BOOLEAN_FALSE, /* Ignored */
                -1, /*Ignored*/
                (char *)"ACSBulkData::BulkDataNTFrame", /* Name */
                NULL, /* Ignored */      
                0, /* Ignored */
                0, /* Ignored */
                NULL, /* Ignored */
                3, /* Number of members */
                BulkDataNTFrame_g_tc_members, /* Members */
                DDS_VM_NONE, /* Ignored */
                RTICdrTypeCodeAnnotations_INITIALIZER,
                DDS_BOOLEAN_TRUE, /* _isCopyable */
                NULL, /* _sampleAccessInfo: assigned later */
                NULL /* _typePlugin: assigned later */
            }}; /* Type code for BulkDataNTFrame*/

        if (is_initialized) {
            return &BulkDataNTFrame_g_tc;
        }

        BulkDataNTFrame_g_tc._data._annotations._allowedDataRepresentationMask = 5;

        BulkDataNTFrame_g_tc_data_sequence._data._typeCode = (RTICdrTypeCode *)&DDS_g_tc_octet_w_new;
        BulkDataNTFrame_g_tc_data_sequence._data._sampleAccessInfo = &DDS_g_sai_octet_seq;
        BulkDataNTFrame_g_tc_members[0]._representation._typeCode = (RTICdrTypeCode *)ACSBulkData::DataType_get_typecode();
        BulkDataNTFrame_g_tc_members[1]._representation._typeCode = (RTICdrTypeCode *)&DDS_g_tc_ulong_w_new;
        BulkDataNTFrame_g_tc_members[2]._representation._typeCode = (RTICdrTypeCode *)& BulkDataNTFrame_g_tc_data_sequence;

        /* Initialize the values for member annotations. */
        BulkDataNTFrame_g_tc_members[0]._annotations._defaultValue._d = RTI_XCDR_TK_ULONG;
        BulkDataNTFrame_g_tc_members[0]._annotations._defaultValue._u.ulong_value = 0u;
        BulkDataNTFrame_g_tc_members[0]._annotations._minValue._d = RTI_XCDR_TK_ULONG;
        BulkDataNTFrame_g_tc_members[0]._annotations._minValue._u.ulong_value = RTIXCdrUnsignedLong_MIN;
        BulkDataNTFrame_g_tc_members[0]._annotations._maxValue._d = RTI_XCDR_TK_ULONG;
        BulkDataNTFrame_g_tc_members[0]._annotations._maxValue._u.ulong_value = RTIXCdrUnsignedLong_MAX;

        BulkDataNTFrame_g_tc_members[1]._annotations._defaultValue._d = RTI_XCDR_TK_ULONG;
        BulkDataNTFrame_g_tc_members[1]._annotations._defaultValue._u.ulong_value = 0u;
        BulkDataNTFrame_g_tc_members[1]._annotations._minValue._d = RTI_XCDR_TK_ULONG;
        BulkDataNTFrame_g_tc_members[1]._annotations._minValue._u.ulong_value = RTIXCdrUnsignedLong_MIN;
        BulkDataNTFrame_g_tc_members[1]._annotations._maxValue._d = RTI_XCDR_TK_ULONG;
        BulkDataNTFrame_g_tc_members[1]._annotations._maxValue._u.ulong_value = RTIXCdrUnsignedLong_MAX;

        BulkDataNTFrame_g_tc._data._sampleAccessInfo =
        BulkDataNTFrame_get_sample_access_info();
        BulkDataNTFrame_g_tc._data._typePlugin =
        BulkDataNTFrame_get_type_plugin_info();    

        is_initialized = RTI_TRUE;

        return &BulkDataNTFrame_g_tc;
    }

    #define TSeq BulkDataNTFrameSeq
    #define T BulkDataNTFrame
    #include "dds_cpp/generic/dds_cpp_data_TInterpreterSupport.gen"
    #undef T
    #undef TSeq

    RTIXCdrSampleAccessInfo *BulkDataNTFrame_get_sample_seq_access_info()
    {
        static RTIXCdrSampleAccessInfo BulkDataNTFrame_g_seqSampleAccessInfo = {
            RTI_XCDR_TYPE_BINDING_CPP, \
            {sizeof(BulkDataNTFrameSeq),0,0,0}, \
            RTI_XCDR_FALSE, \
            DDS_Sequence_get_member_value_pointer, \
            BulkDataNTFrameSeq_set_member_element_count, \
            NULL, \
            NULL, \
            NULL \
        };

        return &BulkDataNTFrame_g_seqSampleAccessInfo;
    }

    RTIXCdrSampleAccessInfo *BulkDataNTFrame_get_sample_access_info()
    {
        static RTIBool is_initialized = RTI_FALSE;

        ACSBulkData::BulkDataNTFrame *sample;

        static RTIXCdrMemberAccessInfo BulkDataNTFrame_g_memberAccessInfos[3] =
        {RTIXCdrMemberAccessInfo_INITIALIZER};

        static RTIXCdrSampleAccessInfo BulkDataNTFrame_g_sampleAccessInfo = 
        RTIXCdrSampleAccessInfo_INITIALIZER;

        if (is_initialized) {
            return (RTIXCdrSampleAccessInfo*) &BulkDataNTFrame_g_sampleAccessInfo;
        }

        RTIXCdrHeap_allocateStruct(
            &sample, 
            ACSBulkData::BulkDataNTFrame);
        if (sample == NULL) {
            return NULL;
        }

        BulkDataNTFrame_g_memberAccessInfos[0].bindingMemberValueOffset[0] = 
        (RTIXCdrUnsignedLong) ((char *)&sample->typeOfdata - (char *)sample);

        BulkDataNTFrame_g_memberAccessInfos[1].bindingMemberValueOffset[0] = 
        (RTIXCdrUnsignedLong) ((char *)&sample->restDataLength - (char *)sample);

        BulkDataNTFrame_g_memberAccessInfos[2].bindingMemberValueOffset[0] = 
        (RTIXCdrUnsignedLong) ((char *)&sample->data - (char *)sample);

        BulkDataNTFrame_g_sampleAccessInfo.memberAccessInfos = 
        BulkDataNTFrame_g_memberAccessInfos;

        {
            size_t candidateTypeSize = sizeof(BulkDataNTFrame);

            if (candidateTypeSize > RTIXCdrUnsignedLong_MAX) {
                BulkDataNTFrame_g_sampleAccessInfo.typeSize[0] =
                RTIXCdrUnsignedLong_MAX;
            } else {
                BulkDataNTFrame_g_sampleAccessInfo.typeSize[0] =
                (RTIXCdrUnsignedLong) candidateTypeSize;
            }
        }

        BulkDataNTFrame_g_sampleAccessInfo.useGetMemberValueOnlyWithRef =
        RTI_XCDR_TRUE;

        BulkDataNTFrame_g_sampleAccessInfo.getMemberValuePointerFcn = 
        BulkDataNTFrame_get_member_value_pointer;

        BulkDataNTFrame_g_sampleAccessInfo.languageBinding = 
        RTI_XCDR_TYPE_BINDING_CPP ;

        RTIXCdrHeap_freeStruct(sample);
        is_initialized = RTI_TRUE;
        return (RTIXCdrSampleAccessInfo*) &BulkDataNTFrame_g_sampleAccessInfo;
    }

    RTIXCdrTypePlugin *BulkDataNTFrame_get_type_plugin_info()
    {
        static RTIXCdrTypePlugin BulkDataNTFrame_g_typePlugin = 
        {
            NULL, /* serialize */
            NULL, /* serialize_key */
            NULL, /* deserialize_sample */
            NULL, /* deserialize_key_sample */
            NULL, /* skip */
            NULL, /* get_serialized_sample_size */
            NULL, /* get_serialized_sample_max_size_ex */
            NULL, /* get_serialized_key_max_size_ex */
            NULL, /* get_serialized_sample_min_size */
            NULL, /* serialized_sample_to_key */
            (RTIXCdrTypePluginInitializeSampleFunction) 
            ACSBulkData::BulkDataNTFrame_initialize_ex,
            NULL,
            (RTIXCdrTypePluginFinalizeSampleFunction)
            ACSBulkData::BulkDataNTFrame_finalize_w_return,
            NULL
        };

        return &BulkDataNTFrame_g_typePlugin;
    }
    #endif

    RTIBool BulkDataNTFrame_initialize(
        BulkDataNTFrame* sample) {
        return ACSBulkData::BulkDataNTFrame_initialize_ex(sample,RTI_TRUE,RTI_TRUE);
    }

    RTIBool BulkDataNTFrame_initialize_ex(
        BulkDataNTFrame* sample,RTIBool allocatePointers, RTIBool allocateMemory)
    {

        struct DDS_TypeAllocationParams_t allocParams =
        DDS_TYPE_ALLOCATION_PARAMS_DEFAULT;

        allocParams.allocate_pointers =  (DDS_Boolean)allocatePointers;
        allocParams.allocate_memory = (DDS_Boolean)allocateMemory;

        return ACSBulkData::BulkDataNTFrame_initialize_w_params(
            sample,&allocParams);

    }

    RTIBool BulkDataNTFrame_initialize_w_params(
        BulkDataNTFrame* sample, const struct DDS_TypeAllocationParams_t * allocParams)
    {

        void* buffer = NULL;
        if (buffer) {} /* To avoid warnings */

        if (sample == NULL) {
            return RTI_FALSE;
        }
        if (allocParams == NULL) {
            return RTI_FALSE;
        }

        sample->typeOfdata = 0u;

        sample->restDataLength = 0u;

        if (allocParams->allocate_memory) {
            if(!DDS_OctetSeq_initialize(&sample->data  )){
                return RTI_FALSE;
            }
            if(!DDS_OctetSeq_set_absolute_maximum(&sample->data , ((ACSBulkData::FRAME_MAX_LEN)))){
                return RTI_FALSE;
            }
            if (!DDS_OctetSeq_set_maximum(&sample->data , ((ACSBulkData::FRAME_MAX_LEN)))) {
                return RTI_FALSE;
            }
        } else { 
            if(!DDS_OctetSeq_set_length(&sample->data, 0)){
                return RTI_FALSE;
            }    
        }
        return RTI_TRUE;
    }

    RTIBool BulkDataNTFrame_finalize_w_return(
        BulkDataNTFrame* sample)
    {
        ACSBulkData::BulkDataNTFrame_finalize_ex(sample, RTI_TRUE);

        return RTI_TRUE;
    }

    void BulkDataNTFrame_finalize(
        BulkDataNTFrame* sample)
    {

        ACSBulkData::BulkDataNTFrame_finalize_ex(sample,RTI_TRUE);
    }

    void BulkDataNTFrame_finalize_ex(
        BulkDataNTFrame* sample,RTIBool deletePointers)
    {
        struct DDS_TypeDeallocationParams_t deallocParams =
        DDS_TYPE_DEALLOCATION_PARAMS_DEFAULT;

        if (sample==NULL) {
            return;
        } 

        deallocParams.delete_pointers = (DDS_Boolean)deletePointers;

        ACSBulkData::BulkDataNTFrame_finalize_w_params(
            sample,&deallocParams);
    }

    void BulkDataNTFrame_finalize_w_params(
        BulkDataNTFrame* sample,const struct DDS_TypeDeallocationParams_t * deallocParams)
    {

        if (sample==NULL) {
            return;
        }

        if (deallocParams == NULL) {
            return;
        }

        if(!DDS_OctetSeq_finalize(&sample->data)){
            return;
        }

    }

    void BulkDataNTFrame_finalize_optional_members(
        BulkDataNTFrame* sample, RTIBool deletePointers)
    {
        struct DDS_TypeDeallocationParams_t deallocParamsTmp =
        DDS_TYPE_DEALLOCATION_PARAMS_DEFAULT;
        struct DDS_TypeDeallocationParams_t * deallocParams =
        &deallocParamsTmp;

        if (sample==NULL) {
            return;
        } 
        if (deallocParams) {} /* To avoid warnings */

        deallocParamsTmp.delete_pointers = (DDS_Boolean)deletePointers;
        deallocParamsTmp.delete_optional_members = DDS_BOOLEAN_TRUE;

    }

    RTIBool BulkDataNTFrame_copy(
        BulkDataNTFrame* dst,
        const BulkDataNTFrame* src)
    {
        try {

            if (dst == NULL || src == NULL) {
                return RTI_FALSE;
            }

            if (!RTICdrType_copyUnsignedLong (
                &dst->typeOfdata, &src->typeOfdata)) { 
                return RTI_FALSE;
            }
            if (!RTICdrType_copyUnsignedLong (
                &dst->restDataLength, &src->restDataLength)) { 
                return RTI_FALSE;
            }
            if (!DDS_OctetSeq_copy(&dst->data ,
            &src->data )) {
                return RTI_FALSE;
            }

            return RTI_TRUE;

        } catch (const std::bad_alloc&) {
            return RTI_FALSE;
        }
    }

    /**
    * <<IMPLEMENTATION>>
    *
    * Defines:  TSeq, T
    *
    * Configure and implement 'BulkDataNTFrame' sequence class.
    */
    #define T BulkDataNTFrame
    #define TSeq BulkDataNTFrameSeq

    #define T_initialize_w_params ACSBulkData::BulkDataNTFrame_initialize_w_params

    #define T_finalize_w_params   ACSBulkData::BulkDataNTFrame_finalize_w_params
    #define T_copy       ACSBulkData::BulkDataNTFrame_copy

    #ifndef NDDS_STANDALONE_TYPE
    #include "dds_c/generic/dds_c_sequence_TSeq.gen"
    #include "dds_cpp/generic/dds_cpp_sequence_TSeq.gen"
    #else
    #include "dds_c_sequence_TSeq.gen"
    #include "dds_cpp_sequence_TSeq.gen"
    #endif

    #undef T_copy
    #undef T_finalize_w_params

    #undef T_initialize_w_params

    #undef TSeq
    #undef T

} /* namespace ACSBulkData  */

#ifndef NDDS_STANDALONE_TYPE
namespace rti { 
    namespace xcdr {
        const RTIXCdrTypeCode * type_code<ACSBulkData::BulkDataNTFrame>::get() 
        {
            return (const RTIXCdrTypeCode *) ACSBulkData::BulkDataNTFrame_get_typecode();
        }

    } 
}
#endif
