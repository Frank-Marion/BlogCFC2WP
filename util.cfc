<cfcomponent name="util">
	<cffunction name="init" access="remote" returnType="void" output="false" hint="Initialize the component">
		<cfset instance = structNew()>
		<cfinclude template="./application.cfm">
		<cfreturn this>
	</cffunction>
	<cffunction name="querytoarray" returntype="array" output="No">
	    <cfargument name="q" required="Yes" type="query">
	    <cfset var aTmp = arraynew(1)>
	    
	    <cfif q.recordcount>
	        <cfloop query="q">
	            <cfset stTmp = structNew()>
	            <cfloop list="#lcase(q.columnlist)#" index="col">
	                <cfset stTmp[col] = q[col][currentRow]>
	            </cfloop>
	    
	            <cfset arrayAppend(aTmp,stTmp)>
	        </cfloop>
	    <cfelse>
	        <cfset stTmp = structNew()>
	        <cfloop list="#lcase(q.columnlist)#" index="col">
	            <cfset stTmp[col] = "">
	        </cfloop>
	
	        <cfset arrayAppend(aTmp,stTmp)>
	    </cfif>
	
	    <cfreturn aTmp>
	</cffunction>
</cfcomponent>