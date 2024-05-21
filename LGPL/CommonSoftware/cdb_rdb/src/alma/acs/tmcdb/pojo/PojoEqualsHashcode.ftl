<#if pojo.needsEqualsHashCode() && !clazz.superclass?exists>
<#assign classNameToCastTo><#if clazz.getProxyInterfaceName?exists>${clazz.getProxyInterfaceName()}<#else>${pojo.getDeclarationName()}</#if></#assign>
<#if pojo.isComponent()>
   public boolean equals(Object other) {
<#else>
   public boolean equalsContent(Object other) {
</#if>
         if ( (this == other ) ) return true;
		 if ( (other == null ) ) return false;
		 if ( !(other instanceof ${classNameToCastTo}) ) return false;
		 ${classNameToCastTo} castOther = ( ${classNameToCastTo} ) other;

		 return ${pojo.generateEquals("this", "castOther", jdk5)};
   }

<#if pojo.isComponent()>
   public int hashCode() {
<#else>
   public int hashCodeContent() {
</#if>
         int result = 17;

<#foreach property in pojo.getAllPropertiesIterator()>         ${pojo.generateHashCode(property, "result", "this", jdk5)}
</#foreach>         return result;
   }
</#if>
