<!-- edited with XMLSPY v5 rel. 2 U (http://www.xmlspy.com) by Bogdan Jeram (E.S.O.) -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:acserr="Alma/ACSError">
	<xsl:output method="text" version="1.0" encoding="ASCII"/>
<!--                                                                BEGIN: template for members          -->
<xsl:template match="acserr:Member">
		 <xsl:variable name="MemberType">
		 <xsl:choose>
					<xsl:when test='@type="string"'>
					<xsl:text>ACE_CString</xsl:text>
					</xsl:when>
					<xsl:when test='@type="boolean"'>
					<xsl:text>bool</xsl:text>
					</xsl:when>
					<xsl:otherwise>
					<xsl:value-of select="@type"/>
					</xsl:otherwise>
		  </xsl:choose>
		</xsl:variable>
<!--                                                                           set member -->
   <xsl:text>void set</xsl:text>
	           <xsl:value-of select="@name"/>
				<xsl:text>(</xsl:text>
				<xsl:value-of select="$MemberType"/>
				<xsl:text> value){ getErrorTraceHelper()->setMemberValue("</xsl:text>
				 <xsl:value-of select="@name"/>
				<xsl:text>", value); }            				
	</xsl:text>
	<!--                                                            get member -->
	<xsl:value-of select="$MemberType"/>
					 <xsl:text> get</xsl:text>
	  	           <xsl:value-of select="@name"/>
        			<xsl:text> (){ return getErrorTraceHelper()->getMemberValue&lt;</xsl:text>
        	<xsl:value-of select="$MemberType"/>
        	<xsl:text>&gt;("</xsl:text>
        			<xsl:value-of select="@name"/>
    			    <xsl:text>");  }
</xsl:text>
</xsl:template>
<!--                                                                END: template for members          -->
		
	<xsl:template match="/acserr:Type">
		<xsl:text>#ifndef _</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>_H_</xsl:text>
		<xsl:text>
#define _</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>_H_

/*******************************************************************************
* ALMA - Atacama Large Millimiter Array
* (c) European Southern Observatory, 2003 
*
*This library is free software; you can redistribute it and/or
*modify it under the terms of the GNU Lesser General Public
*License as published by the Free Software Foundation; either
*version 2.1 of the License, or (at your option) any later version.
*
*This library is distributed in the hope that it will be useful,
*but WITHOUT ANY WARRANTY; without even the implied warranty of
*MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*Lesser General Public License for more details.
*
*You should have received a copy of the GNU Lesser General Public
*License along with this library; if not, write to the Free Software
*Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*
* "@(#) $Id: AES2H.xslt,v 1.27 2012/02/29 12:50:09 tstaig Exp $"
*************  THIS FILE IS AUTOMATICALLY GENERATED !!!!!!
*/
	
#include "</xsl:text>
		<xsl:value-of select="@name"/>C.h"
<xsl:text>
#include "acserrExceptionManager.h"
#include "acserrGenExport.h"

</xsl:text>
		<xsl:if test="count(//acserr:Code)+count(//acserr:ErrorCode) > 0">
			<xsl:text>namespace </xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:text>
{

</xsl:text>
			<!--		<xsl:text>
	const char[][50] = {</xsl:text>
		<xsl:for-each select="Code">
			<xsl:text>"</xsl:text>
			<xsl:value-of select="@shortDescription"/>
			<xsl:text>"</xsl:text>
			<xsl:if test="not (position() = last())">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>};</xsl:text>
-->
			<!--  ******************************************** Code *************************************************************************************************************************** -->
			<xsl:for-each select="acserr:Code">
				<xsl:variable name="CompName">
					<xsl:value-of select="@name"/>
					<xsl:text>Completion</xsl:text>
				</xsl:variable>
				<xsl:text>class acserrGen_EXPORT </xsl:text>
				<xsl:value-of select="$CompName"/>
				<xsl:text>: public ACSErr::CompletionImpl
{
	static const ACSErr::ACSErrType m_etype=ACSErr::</xsl:text>
				<xsl:value-of select="../@name"/>
				<xsl:text>; // = </xsl:text>
				<xsl:value-of select="../@type"/>
				<xsl:text>
	static const ACSErr::ErrorCode m_code = </xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>;
	static const char m_shortDescription[];
		
	public:
	
	static bool isEqual(ACSErr::Completion &amp;completion);
		
	const char * getShortDescription() { return </xsl:text>
	<xsl:value-of select="$CompName"/>
	<xsl:text>::m_shortDescription; }
	</xsl:text>
				<xsl:value-of select="$CompName"/>
				<xsl:text> () : ACSErr::CompletionImpl(m_etype, m_code) {}				
 };
 
</xsl:text>
			</xsl:for-each>
			<!--  ******************************************** ErrorCode *************************************************************************************************************************** -->
			<xsl:for-each select="acserr:ErrorCode">
				<xsl:variable name="CompName">
					<xsl:value-of select="@name"/>
					<xsl:text>Completion</xsl:text>
				</xsl:variable>
				<xsl:text>class acserrGen_EXPORT </xsl:text>
				<xsl:value-of select="$CompName"/>
				<xsl:text>: public ACSErr::CompletionImpl
{
	static const ACSErr::ACSErrType m_etype=ACSErr::</xsl:text>
				<xsl:value-of select="../@name"/>
				<xsl:text>; // = </xsl:text>
				<xsl:value-of select="../@type"/>
				<xsl:text>
	static const ACSErr::ErrorCode m_code = </xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>;
	static const char m_shortDescription[];
		
	public:
	
	static bool isEqual(ACSErr::Completion &amp;completion);
	
	const char * getShortDescription() { return </xsl:text>
	<xsl:value-of select="$CompName"/>
	<xsl:text>::m_shortDescription; }
		
	</xsl:text>
				<xsl:value-of select="$CompName"/>
				<xsl:text> (const char* file, int line, const char* routine, ACSErr::Severity severity=DEFAULT_SEVERITY) : 
		ACSErr::CompletionImpl(m_etype, m_code, file, line, routine, m_shortDescription, severity) {}
					
	</xsl:text>
				<xsl:value-of select="$CompName"/>
				<xsl:text> (ACSErr::Completion *pc, const char* file, int line, const char* routine, ACSErr::Severity severity=DEFAULT_SEVERITY) : 
		ACSErr::CompletionImpl(*pc, m_etype, m_code, file, line, routine, m_shortDescription, severity) {}
		
	</xsl:text>
				<xsl:value-of select="$CompName"/>
				<xsl:text> (const ACSErr::Completion &amp;pc, const char* file, int line, const char* routine, ACSErr::Severity severity=DEFAULT_SEVERITY) : 
		ACSErr::CompletionImpl(pc, m_etype, m_code, file, line, routine, m_shortDescription, severity) {}
		
	</xsl:text>
				<xsl:value-of select="$CompName"/>
				<xsl:text> (ACSErr::CompletionImpl *pc, const char* file, int line, const char* routine, ACSErr::Severity severity=DEFAULT_SEVERITY) : 
		ACSErr::CompletionImpl(pc, m_etype, m_code, file, line, routine, m_shortDescription, severity) {}
		
	</xsl:text>
				<xsl:value-of select="$CompName"/>
				<xsl:text> (const ACSErr::ErrorTrace &amp;et, const char* file, int line, const char* routine, ACSErr::Severity severity=DEFAULT_SEVERITY) : 
		ACSErr::CompletionImpl(et, m_etype, m_code, file, line, routine, m_shortDescription, severity) {}	
						
	template &lt;class T &gt;
	</xsl:text>
				<xsl:value-of select="$CompName"/>
				<xsl:text> (const T &amp;pe, const char* file, int line, const char* routine, ACSErr::Severity severity=DEFAULT_SEVERITY) : 
		ACSErr::CompletionImpl(ETHolder&lt;T&gt;(pe).getErrorTrace(), m_etype, m_code, file, line, routine, m_shortDescription, severity) {}
</xsl:text>
<!--             *******************************************************                                    members -->
<xsl:apply-templates/>
<xsl:text>
};

</xsl:text>
			</xsl:for-each>
			<!--  ************************************************************************************************************************************************************************* -->
			
<xsl:if test="count(//acserr:ErrorCode[not(@_suppressExceptionGeneration)]) > 0">
			<xsl:text>
 // ******************************************************************* 
 //                                excptions for type:
 // ******************************************************************* 
</xsl:text>			
            <xsl:variable name="TypeExName">
				<xsl:value-of select="@name"/>
				<xsl:text>ExImpl</xsl:text>
			</xsl:variable>
			<xsl:variable name="IDLTypeExName">
				<xsl:value-of select="@name"/>::<xsl:value-of select="@name"/>
				<xsl:text>Ex</xsl:text>
			</xsl:variable>
			<xsl:text>class </xsl:text>
			<xsl:value-of select="$TypeExName"/>
			<xsl:text> : public ACSErr::ACSbaseExImpl
{
	protected:
	</xsl:text>
			<xsl:value-of select="$TypeExName"/>
			<xsl:text>(const ACSErr::ErrorTrace &amp;et) : ACSErr::ACSbaseExImpl(et) {}
	
	</xsl:text>
			<xsl:value-of select="$TypeExName"/>
			<xsl:text> (ACSErr::ACSErrType et, ACSErr::ErrorCode ec, const char* file, 
						int line, const char* routine, const char* sd,
					   	ACSErr::Severity severity):
		   			ACSErr::ACSbaseExImpl(et, ec, file, line, routine, sd, severity) {}
				
	</xsl:text>
			<xsl:value-of select="$TypeExName"/>
			<xsl:text> (const ACSErr::ErrorTrace &amp;pet,
						   ACSErr::ACSErrType et, ACSErr::ErrorCode ec,
						   const char* file, int line, const char* routine, const char* sd, 
						   ACSErr::Severity severity) :
					ACSErr::ACSbaseExImpl(pet, et, ec, file, line, routine, sd, severity) {}
	
	public:
					
	</xsl:text>
			<xsl:value-of select="$TypeExName"/>
			<xsl:text> (</xsl:text>
			<xsl:value-of select="$IDLTypeExName"/>
			<xsl:text> &amp; ex) : ACSErr::ACSbaseExImpl(ex.errorTrace) {}
			
	</xsl:text>
			<xsl:value-of select="$IDLTypeExName"/>
			<xsl:text> get</xsl:text>
			<xsl:value-of select="@name"/>
			<xsl:text>Ex () { return </xsl:text>
			<xsl:value-of select="$IDLTypeExName"/>
			<xsl:text> (getErrorTrace()); }
};

</xsl:text>
			<xsl:text>
 // ******************************************************************* 
 //                                excptions for codes:
 // ******************************************************************* 
</xsl:text>
			<!--  exceptions for codes ************************************************************************************************************************************************************************* -->
			<xsl:for-each select="acserr:ErrorCode[not (@_suppressExceptionGeneration)]">
				<xsl:variable name="ExName">
					<xsl:value-of select="@name"/>
					<xsl:text>ExImpl</xsl:text>
				</xsl:variable>
				<xsl:variable name="IDLExName">
					<xsl:value-of select="../@name"/>::<xsl:value-of select="@name"/>
					<xsl:text>Ex</xsl:text>
				</xsl:variable>
				<xsl:text>class acserrGen_EXPORT </xsl:text>
				<xsl:value-of select="$ExName"/>
				<xsl:text>: public </xsl:text>
				<xsl:value-of select="$TypeExName"/>
				<xsl:text>
{
	static const ACSErr::ACSErrType m_etype=ACSErr::</xsl:text>
				<xsl:value-of select="../@name"/>
				<xsl:text>;
	static const ACSErr::ErrorCode m_code = </xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>;
	static const char m_shortDescription[]  ;
	
	public:
		static bool isEqual(ACSErr::ACSbaseExImpl &amp;ex);

        static const char * getShortDescription() { return m_shortDescription;}
	</xsl:text>
				<xsl:value-of select="$ExName"/>
				<xsl:text>(const </xsl:text>
				<xsl:value-of select="$ExName"/>
				<xsl:text>&amp; ex) :
			</xsl:text>
				<xsl:value-of select="$TypeExName"/>
				<xsl:text>(const_cast&lt;</xsl:text> 
				<xsl:value-of select="$ExName"/>
				<xsl:text>&amp;&gt;(ex).getErrorTrace()) {}
		
	</xsl:text>
				<xsl:value-of select="$ExName"/>
				<xsl:text> (const char* file, int line, const char* routine, ACSErr::Severity severity=DEFAULT_SEVERITY) : 
			</xsl:text>
				<xsl:value-of select="$TypeExName"/>
				<xsl:text>(m_etype, m_code, file, line, routine, m_shortDescription, severity) {}
	
	</xsl:text>
				<xsl:value-of select="$ExName"/>
				<xsl:text> (const ACSErr::ErrorTrace &amp;et, const char* file, int line, const char* routine, ACSErr::Severity severity=DEFAULT_SEVERITY) : 
			</xsl:text>
				<xsl:value-of select="$TypeExName"/>
				<xsl:text>(et, m_etype, m_code, file, line, routine, m_shortDescription, severity) {}
				
	</xsl:text>
				<xsl:value-of select="$ExName"/>
				<xsl:text> (ACSErr::CompletionImpl *pc, const char* file, int line, const char* routine, ACSErr::Severity severity=DEFAULT_SEVERITY) : 
			</xsl:text>
				<xsl:value-of select="$TypeExName"/>
				<xsl:text>((pc->isErrorFree() ? ACSErr::ErrorTrace()  : pc->getErrorTraceHelper()->getErrorTrace()), m_etype, m_code, file, line, routine, m_shortDescription, severity) {}
				
	</xsl:text>
				<xsl:value-of select="$ExName"/>
				<xsl:text> (const </xsl:text>
				<xsl:value-of select="$IDLExName"/>
				<xsl:text> &amp; ex) : 
			</xsl:text>
				<xsl:value-of select="$TypeExName"/>
				<xsl:text>(ex.errorTrace) {}
			
	</xsl:text>
				<xsl:value-of select="$IDLExName"/>
				<xsl:text> get</xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>Ex () { return </xsl:text>
				<xsl:value-of select="$IDLExName"/>
				<xsl:text> (getErrorTrace()); }
	</xsl:text>
				
	<xsl:text>
	template &lt;class T &gt;
	</xsl:text>
				<xsl:value-of select="$ExName"/>
				<xsl:text> (const T&amp; pe, const char* file, int line, const char* routine, ACSErr::Severity severity=DEFAULT_SEVERITY) : 
			</xsl:text>
				<xsl:value-of select="$TypeExName"/>
				<xsl:text>(ETHolder&lt;T&gt;(pe).getErrorTrace(), m_etype, m_code, file, line, routine, m_shortDescription, severity) {}

</xsl:text>
<!--             *******************************************************                                    members -->
<xsl:apply-templates/>
<xsl:text>
};

</xsl:text>
			</xsl:for-each>
</xsl:if>
			<xsl:text>}
</xsl:text>
		</xsl:if>
		<xsl:text>
#endif
</xsl:text>
	</xsl:template>
</xsl:stylesheet>