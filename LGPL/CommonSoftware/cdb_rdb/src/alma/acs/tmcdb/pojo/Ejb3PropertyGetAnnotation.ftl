<#if ejb3>
<#if pojo.hasIdentifierProperty()>
<#if property.equals(clazz.identifierProperty)>
<#if pojo.hasMetaAttribute("oracle-sequence") >
    @${pojo.importType("jakarta.persistence.Id")} @${pojo.importType("jakarta.persistence.GeneratedValue")}(generator="${property.getPersistentClass().getClassName().replace('.','_')}_${pojo.getPropertyName(property)}Generator")
    @${pojo.importType("org.hibernate.annotations.GenericGenerator")}(name="${property.getPersistentClass().getClassName().replace('.','_')}_${pojo.getPropertyName(property)}Generator", strategy="native",
       parameters = {@${pojo.importType("org.hibernate.annotations.Parameter")}(name="sequence_name", value="${pojo.getMetaAsString("oracle-sequence")}")}
	)
<#else>
<#-- Needed for Hibernate Tools 6.2+ -->
<#if property.getValue().getIdentifierGeneratorStrategy().equals("foreign")>
<#assign genProps = property.getValue().getIdentifierGeneratorProperties()>
${genProps.setProperty("property", pojo.getPropertyName(property)?remove_ending("Id")?uncap_first)!""}
${property.getValue().setIdentifierGeneratorProperties(genProps)}
</#if>
<#-- -->
${pojo.generateAnnIdGenerator().replace('.','_')}
</#if>
</#if>
</#if>

<#if c2h.isOneToOne(property)>
${pojo.generateOneToOneAnnotation(property, md)}
<#elseif c2h.isManyToOne(property)>
<#-- Needed for Hibernate Tools 6.1+ -->
<#if !clazz.identifierProperty.getValue().getColumns().contains(property.getValue().getColumns().get(0))>
${property.setInsertable(true)}
${property.setUpdateable(true)}
</#if>
<#-- -->
${pojo.generateManyToOneAnnotation(property)}
<#--TODO support optional and targetEntity-->    
${pojo.generateJoinColumnsAnnotation(property, md).replaceFirst("=\"", "=\"`").replaceAll("\",", "`\",").replaceAll("\"\\)","`\")")}
<#elseif c2h.isCollection(property)>
<#-- Needed for Hibernate Tools 6.1+ -->
${property.setInsertable(true)}
<#-- -->
${pojo.generateCollectionAnnotation(property, md).replace(", schema=\"PUBLIC\"","").replace(", catalog=\"PUBLIC\"", "")}
<#else>
${pojo.generateBasicAnnotation(property)}
${pojo.generateAnnColumnAnnotation(property).replaceFirst("=\"", "=\"`").replaceAll("\",", "`\",").replaceAll("\"\\)","`\")")}
<#-- Added by ACS to support the @Type annotation -->
<#if pojo.getMetaAttribAsBool(property, "isXmlClobType", false) >
    @${pojo.importType("org.hibernate.annotations.JdbcTypeCode")}(${pojo.importType("org.hibernate.type.SqlTypes")}.SQLXML)
</#if>
<#assign name = pojo.getPropertyName(property)?lower_case>
<#if pojo.getMetaAsString("enum-types")?contains(name+"|")>
	<#list pojo.getMetaAsString("enum-types")?split(",")?filter(pair -> pair?split('|')?first == pojo.getPropertyName(property)?lower_case) as pair>
	<#assign pairContent = pair?split('|')>
	<#assign typeDefName = pairContent?last?split('.')?last>
	@${pojo.importType("org.hibernate.annotations.Type")}(value=${pojo.importType("alma.hibernate.util.StringEnumUserType")}.class, parameters={ @${pojo.importType("org.hibernate.annotations.Parameter")}(name="enumClassName", value="${pairContent?last}") })<#if pair_has_next>,</#if>
	</#list>
</#if>
</#if>
</#if>
