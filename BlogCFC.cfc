<cfcomponent name="BlogCFC">
	<cffunction name="init" access="remote" returnType="void" output="false" hint="Initialize the component">
		<cfset instance = structNew()>
		<cfinclude template="./application.cfm">
		<cfreturn this>
	</cffunction>
 	<cffunction name="getAllCategories" access="public" returntype="query" output="false" hint="I return a query object of all the categories from the BlogCFC db">
		<cfset var qAllCats = "">
		<cfset var aBlankArray = ArrayNew(1)>
		<!--- query the categories table --->
		<cfquery name="qAllCats" datasource="#application.blogCFC.datasource#">
			SELECT * FROM tblblogcategories
		</cfquery>
		<cfset QueryAddColumn(qAllCats,"NewWPcatID",aBlankArray)>
		<cfreturn qAllCats>
	</cffunction> 
 	<cffunction name="getAllPosts" access="public" returntype="query" output="false" hint="I return a query object of all the entries from the BlogCFC db">
		<cfset var qAllPosts = "">
		<cfset var aBlankArray = ArrayNew(1)>
		<!--- query the categories table --->
		<cfquery name="qAllPosts" datasource="#application.blogCFC.datasource#">
			SELECT * FROM tblblogentries
		</cfquery>
		<cfset QueryAddColumn(qAllPosts,"NewWPpostID",aBlankArray)>
		<cfreturn qAllPosts>
	</cffunction> 
 	<cffunction name="getAllComments" access="public" returntype="query" output="false" hint="I return a query obj of all comments from BlogCFC">
		<cfset var qAllComments = "">
		<cfquery name="qAllComments" datasource="#application.blogCFC.datasource#">
			SELECT * FROM tblblogcomments
		</cfquery>
		<cfreturn qAllComments>
	</cffunction> 
</cfcomponent>
