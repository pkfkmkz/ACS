

/*
WARNING: THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.

This file was generated from bulkDataNT.idl using "rtiddsgen".
The rtiddsgen tool is part of the RTI Connext distribution.
For more information, type 'rtiddsgen -help' at a command shell
or consult the RTI Connext manual.
*/

#ifndef bulkDataNTPlugin_1411991815_h
#define bulkDataNTPlugin_1411991815_h

#include "bulkDataOpenDDS.h"

struct RTICdrStream;

#ifndef pres_typePlugin_h
#include "pres/pres_typePlugin.h"
#endif

#if (defined(RTI_WIN32) || defined (RTI_WINCE) || defined(RTI_INTIME)) && defined(NDDS_USER_DLL_EXPORT)
/* If the code is building on Windows, start exporting symbols.
*/
#undef NDDSUSERDllExport
#define NDDSUSERDllExport __declspec(dllexport)
#endif

namespace ACSBulkData {

    #define DataTypePlugin_get_sample PRESTypePluginDefaultEndpointData_getSample 

    #define DataTypePlugin_get_buffer PRESTypePluginDefaultEndpointData_getBuffer 
    #define DataTypePlugin_return_buffer PRESTypePluginDefaultEndpointData_returnBuffer

    #define DataTypePlugin_create_sample PRESTypePluginDefaultEndpointData_createSample 
    #define DataTypePlugin_destroy_sample PRESTypePluginDefaultEndpointData_deleteSample 

    /* --------------------------------------------------------------------------------------
    Support functions:
    * -------------------------------------------------------------------------------------- */

    NDDSUSERDllExport extern DataType*
    DataTypePluginSupport_create_data_w_params(
        const struct DDS_TypeAllocationParams_t * alloc_params);

    NDDSUSERDllExport extern DataType*
    DataTypePluginSupport_create_data_ex(RTIBool allocate_pointers);

    NDDSUSERDllExport extern DataType*
    DataTypePluginSupport_create_data(void);

    NDDSUSERDllExport extern RTIBool 
    DataTypePluginSupport_copy_data(
        DataType *out,
        const DataType *in);

    NDDSUSERDllExport extern void 
    DataTypePluginSupport_destroy_data_w_params(
        DataType *sample,
        const struct DDS_TypeDeallocationParams_t * dealloc_params);

    NDDSUSERDllExport extern void 
    DataTypePluginSupport_destroy_data_ex(
        DataType *sample,RTIBool deallocate_pointers);

    NDDSUSERDllExport extern void 
    DataTypePluginSupport_destroy_data(
        DataType *sample);

    NDDSUSERDllExport extern void 
    DataTypePluginSupport_print_data(
        const DataType *sample,
        const char *desc,
        unsigned int indent);

    /* ----------------------------------------------------------------------------
    Callback functions:
    * ---------------------------------------------------------------------------- */

    NDDSUSERDllExport extern RTIBool 
    DataTypePlugin_copy_sample(
        PRESTypePluginEndpointData endpoint_data,
        DataType *out,
        const DataType *in);

    /* ----------------------------------------------------------------------------
    (De)Serialize functions:
    * ------------------------------------------------------------------------- */

    NDDSUSERDllExport extern unsigned int 
    DataTypePlugin_get_serialized_sample_max_size(
        PRESTypePluginEndpointData endpoint_data,
        RTIBool include_encapsulation,
        RTIEncapsulationId encapsulation_id,
        unsigned int current_alignment);

    /* --------------------------------------------------------------------------------------
    Key Management functions:
    * -------------------------------------------------------------------------------------- */
    NDDSUSERDllExport extern PRESTypePluginKeyKind 
    DataTypePlugin_get_key_kind(void);

    NDDSUSERDllExport extern unsigned int 
    DataTypePlugin_get_serialized_key_max_size(
        PRESTypePluginEndpointData endpoint_data,
        RTIBool include_encapsulation,
        RTIEncapsulationId encapsulation_id,
        unsigned int current_alignment);

    NDDSUSERDllExport extern unsigned int 
    DataTypePlugin_get_serialized_key_max_size_for_keyhash(
        PRESTypePluginEndpointData endpoint_data,
        RTIEncapsulationId encapsulation_id,
        unsigned int current_alignment);

    #define BulkDataNTFramePlugin_get_sample PRESTypePluginDefaultEndpointData_getSample 

    #define BulkDataNTFramePlugin_get_buffer PRESTypePluginDefaultEndpointData_getBuffer 
    #define BulkDataNTFramePlugin_return_buffer PRESTypePluginDefaultEndpointData_returnBuffer

    #define BulkDataNTFramePlugin_create_sample PRESTypePluginDefaultEndpointData_createSample 
    #define BulkDataNTFramePlugin_destroy_sample PRESTypePluginDefaultEndpointData_deleteSample 

    /* --------------------------------------------------------------------------------------
    Support functions:
    * -------------------------------------------------------------------------------------- */

    NDDSUSERDllExport extern BulkDataNTFrame*
    BulkDataNTFramePluginSupport_create_data_w_params(
        const struct DDS_TypeAllocationParams_t * alloc_params);

    NDDSUSERDllExport extern BulkDataNTFrame*
    BulkDataNTFramePluginSupport_create_data_ex(RTIBool allocate_pointers);

    NDDSUSERDllExport extern BulkDataNTFrame*
    BulkDataNTFramePluginSupport_create_data(void);

    NDDSUSERDllExport extern RTIBool 
    BulkDataNTFramePluginSupport_copy_data(
        BulkDataNTFrame *out,
        const BulkDataNTFrame *in);

    NDDSUSERDllExport extern void 
    BulkDataNTFramePluginSupport_destroy_data_w_params(
        BulkDataNTFrame *sample,
        const struct DDS_TypeDeallocationParams_t * dealloc_params);

    NDDSUSERDllExport extern void 
    BulkDataNTFramePluginSupport_destroy_data_ex(
        BulkDataNTFrame *sample,RTIBool deallocate_pointers);

    NDDSUSERDllExport extern void 
    BulkDataNTFramePluginSupport_destroy_data(
        BulkDataNTFrame *sample);

    NDDSUSERDllExport extern void 
    BulkDataNTFramePluginSupport_print_data(
        const BulkDataNTFrame *sample,
        const char *desc,
        unsigned int indent);

    /* ----------------------------------------------------------------------------
    Callback functions:
    * ---------------------------------------------------------------------------- */

    NDDSUSERDllExport extern PRESTypePluginParticipantData 
    BulkDataNTFramePlugin_on_participant_attached(
        void *registration_data, 
        const struct PRESTypePluginParticipantInfo *participant_info,
        RTIBool top_level_registration, 
        void *container_plugin_context,
        RTICdrTypeCode *typeCode);

    NDDSUSERDllExport extern void 
    BulkDataNTFramePlugin_on_participant_detached(
        PRESTypePluginParticipantData participant_data);

    NDDSUSERDllExport extern PRESTypePluginEndpointData 
    BulkDataNTFramePlugin_on_endpoint_attached(
        PRESTypePluginParticipantData participant_data,
        const struct PRESTypePluginEndpointInfo *endpoint_info,
        RTIBool top_level_registration, 
        void *container_plugin_context);

    NDDSUSERDllExport extern void 
    BulkDataNTFramePlugin_on_endpoint_detached(
        PRESTypePluginEndpointData endpoint_data);

    NDDSUSERDllExport extern void    
    BulkDataNTFramePlugin_return_sample(
        PRESTypePluginEndpointData endpoint_data,
        BulkDataNTFrame *sample,
        void *handle);    

    NDDSUSERDllExport extern RTIBool 
    BulkDataNTFramePlugin_copy_sample(
        PRESTypePluginEndpointData endpoint_data,
        BulkDataNTFrame *out,
        const BulkDataNTFrame *in);

    /* ----------------------------------------------------------------------------
    (De)Serialize functions:
    * ------------------------------------------------------------------------- */

    NDDSUSERDllExport extern RTIBool
    BulkDataNTFramePlugin_serialize_to_cdr_buffer(
        char * buffer,
        unsigned int * length,
        const BulkDataNTFrame *sample); 

    NDDSUSERDllExport extern RTIBool
    BulkDataNTFramePlugin_serialize_to_cdr_buffer_ex(
        char *buffer,
        unsigned int *length,
        const BulkDataNTFrame *sample,
        DDS_DataRepresentationId_t representation);

    NDDSUSERDllExport extern RTIBool 
    BulkDataNTFramePlugin_deserialize(
        PRESTypePluginEndpointData endpoint_data,
        BulkDataNTFrame **sample, 
        RTIBool * drop_sample,
        struct RTICdrStream *stream,
        RTIBool deserialize_encapsulation,
        RTIBool deserialize_sample, 
        void *endpoint_plugin_qos);

    NDDSUSERDllExport extern RTIBool
    BulkDataNTFramePlugin_deserialize_from_cdr_buffer(
        BulkDataNTFrame *sample,
        const char * buffer,
        unsigned int length);    
    #ifndef NDDS_STANDALONE_TYPE
    NDDSUSERDllExport extern DDS_ReturnCode_t
    BulkDataNTFramePlugin_data_to_string(
        const BulkDataNTFrame *sample,
        char *str,
        DDS_UnsignedLong *str_size, 
        const struct DDS_PrintFormatProperty *property);    
    #endif

    NDDSUSERDllExport extern unsigned int 
    BulkDataNTFramePlugin_get_serialized_sample_max_size(
        PRESTypePluginEndpointData endpoint_data,
        RTIBool include_encapsulation,
        RTIEncapsulationId encapsulation_id,
        unsigned int current_alignment);

    /* --------------------------------------------------------------------------------------
    Key Management functions:
    * -------------------------------------------------------------------------------------- */
    NDDSUSERDllExport extern PRESTypePluginKeyKind 
    BulkDataNTFramePlugin_get_key_kind(void);

    NDDSUSERDllExport extern unsigned int 
    BulkDataNTFramePlugin_get_serialized_key_max_size(
        PRESTypePluginEndpointData endpoint_data,
        RTIBool include_encapsulation,
        RTIEncapsulationId encapsulation_id,
        unsigned int current_alignment);

    NDDSUSERDllExport extern unsigned int 
    BulkDataNTFramePlugin_get_serialized_key_max_size_for_keyhash(
        PRESTypePluginEndpointData endpoint_data,
        RTIEncapsulationId encapsulation_id,
        unsigned int current_alignment);

    NDDSUSERDllExport extern RTIBool 
    BulkDataNTFramePlugin_deserialize_key(
        PRESTypePluginEndpointData endpoint_data,
        BulkDataNTFrame ** sample,
        RTIBool * drop_sample,
        struct RTICdrStream *stream,
        RTIBool deserialize_encapsulation,
        RTIBool deserialize_key,
        void *endpoint_plugin_qos);

    NDDSUSERDllExport extern
    struct RTIXCdrInterpreterPrograms *BulkDataNTFramePlugin_get_programs();

    /* Plugin Functions */
    NDDSUSERDllExport extern struct PRESTypePlugin*
    BulkDataNTFramePlugin_new(void);

    NDDSUSERDllExport extern void
    BulkDataNTFramePlugin_delete(struct PRESTypePlugin *);

} /* namespace ACSBulkData  */

#if (defined(RTI_WIN32) || defined (RTI_WINCE) || defined(RTI_INTIME)) && defined(NDDS_USER_DLL_EXPORT)
/* If the code is building on Windows, stop exporting symbols.
*/
#undef NDDSUSERDllExport
#define NDDSUSERDllExport
#endif

#endif /* bulkDataNTPlugin_1411991815_h */

