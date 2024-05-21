@SuppressWarnings("serial")
<#if ejb3?if_exists>
<#if pojo.isComponent()>
@${pojo.importType("jakarta.persistence.Embeddable")}
<#else>
@${pojo.importType("jakarta.persistence.Entity")}
@${pojo.importType("jakarta.persistence.Table")}(name="`${clazz.table.name}`"
<#-- We are commenting these two attributes since we need them to NOT be present in our generated pojos,
     mainly because of the Oracle DB not being complaint with the PUBLIC schema
     that is auto-generated when importing the SQL code from HSQLDB
<#if clazz.table.schema?exists>
    ,schema="${clazz.table.schema}"
</#if><#if clazz.table.catalog?exists>
    ,catalog="${clazz.table.catalog}"
</#if>
-->
<#assign uniqueConstraint=pojo.generateAnnTableUniqueConstraint()>
<#if uniqueConstraint?has_content>
    , uniqueConstraints = ${uniqueConstraint.replaceAll("\",", "`\",").replaceAll("\"}", "`\"}").replaceAll(", \"", ", \"`").replaceFirst("\"", "\"`").replaceAll("\"\\)","`\")")}
</#if>)
<#if pojo.getMetaAttribAsBool(pojo.getDecoratedObject(), "isSuperClass", false)>
@${pojo.importType("jakarta.persistence.Inheritance")}(strategy=${pojo.importType("jakarta.persistence.InheritanceType")}.JOINED)
</#if>
</#if>
</#if>
