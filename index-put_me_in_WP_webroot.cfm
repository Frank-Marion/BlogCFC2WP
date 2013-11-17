<cfapplication name="MyWordPressBlog">
<!--- init all the variables --->
<cfscript>
	theOldPostID = "";
	theNewPostID = "";
	theNewLink= "/index.php";
</cfscript>
<cfparam name="application.qPosts" default="">
<cfif not isQuery("#application.qPosts#") or isDefined("url.reinit")>
<!--- read in the qBlogCFCPosts.xml file and deserialize to a queryobject stored in app scope. --->
	<cffile action="read" file="#ExpandPath('./')#qBlogCFCposts.xml" variable="wddxBlogCFCposts">
	<cfwddx action="wddx2cfml" input="#wddxBlogCFCposts#" output="application.qPosts"> 
</cfif> 
<!--- get the BlogCFCID for this post --->
<!--- if there's something in the querystring then it's the UUID style link --->
<cfif len(cgi.QUERY_STRING)>
	<cfset theOldPostID = ListLast(ListLast(cgi.QUERY_STRING,"&"),"=")>
	<cfquery name="getBlogCFCID" dbtype="query">
		SELECT NEWWPPOSTID from application.qPosts
		WHERE ID  = '#theOldPostID#'
	</cfquery>

<!--- if not, check to see if we can find SEF style link from path info--->
<cfelseif cgi.PATH_INFO neq "/index.cfm">
<cfquery name="getBlogCFCID" dbtype="query">
	SELECT NEWWPPOSTID from application.qPosts
	WHERE lower(alias) = '#lcase(ListLast(cgi.PATH_INFO,"/"))#'
</cfquery>
<cfoutput>'#ListLast(cgi.PATH_INFO,"/")#'</cfoutput>

<!--- else redirect them --->
<cfelse>
	<cflocation url="#theNewLink#" addtoken="no">
</cfif>
<cfif getBlogCFCID.recordcount eq 1>
	<!--- laziness... could support permalinks w/ effort but just going to redirect user to the querystring style URL for the post --->
	<cfset theNewLink = theNewLink & "?p=#getBlogCFCID.Newwppostid#">
	<cflocation url="#theNewLink#" addtoken="no">
<cfelse>
	no entry found for this link, redirecting you to the homepage instead
	<cfoutput><meta http-equiv="refresh" content="3;url=#theNewLink#"></cfoutput>
</cfif>
