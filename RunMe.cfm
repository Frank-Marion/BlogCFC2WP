<!--- CATEGORIES --->
<cfset countCat = 0>
<!--- get all categories from BlogCFC and store in a local query object w/ added newWPID field ---> 
<cfinvoke component="BlogCFC" method="getAllCategories" returnvariable="qBlogCFCcats"/>
<!--- loop over the items in this object  --->
<cfloop query="qBlogCFCcats">
	<!--- insert into Wordpress and get the new category ID for this category and store in NewWPcatID --->
	<cfinvoke component="Wordpress" method="insertCategory" returnvariable="qBlogCFCcats.newWPcatID">
		<cfinvokeargument name="Catname" value="#categoryName#">
	</cfinvoke>
	<cfset countCat = countCat + 1>
</cfloop>
<li>NUM CATEGORIES ADDED: <cfoutput>#countCat#</cfoutput></li> <cfflush>
<!--- serialize this query and write it to a file so that we can comment-out the above function and just read in the query object if we need to run the script again --->
<cfwddx action="cfml2wddx" input="#qBlogCFCcats#" output="wddxBlogCFCcats">
<cffile action="write" file="#ExpandPath('./')#qBlogCFCcats.xml" output="#wddxBlogCFCcats#">
<!--- <cffile action="read" file="#ExpandPath('./')#qBlogCFCcats.xml" variable="wddxBlogCFCcats">
<cfwddx action="wddx2cfml" input="#wddxBlogCFCcats#" output="qBlogCFCcats"> --->
<!--- <cfdump var="#qBlogCFCcats#">  --->

<!--- POSTS --->
<!--- get all posts from BlogCFC and store in a local query object w/ added newWPID field ---> 
<cfinvoke component="BlogCFC" method="getAllPosts" returnvariable="qBlogCFCposts"/>
<!--- turn this query object into an array so we can pass each record individually --->
<cfinvoke component="util" method="querytoarray" returnvariable="AllPostArray">
	<cfinvokeargument name="q" value="#qBlogCFCposts#">
</cfinvoke>
<!--- loop over the items --->
<cfloop from="1" to="#ArrayLen(AllPostArray)#" index="i">
	<!--- insert each into Wordpress and get the new PostID remember it for the category mapping we need to do later --->
	<cfinvoke component="Wordpress" method="insertPost" returnvariable="theNewWPpostID">
		<cfinvokeargument name="postObj" value="#AllPostArray[i]#">
	</cfinvoke> 
<cfset querySetCell(qBlogCFCposts,"newWPpostID",theNewWPpostID,i)>
</cfloop> 
<li>NUM POSTS ADDED: <cfoutput>#ArrayLen(AllPostArray)#</cfoutput></li> <cfflush> 
<!--- serialize this query and write it to a file so that we can comment-out the above function and just read in the query object if we need to run the script again --->
<cfwddx action="cfml2wddx" input="#qBlogCFCposts#" output="wddxBlogCFCposts">
<cffile action="write" file="#ExpandPath('./')#qBlogCFCposts.xml" output="#wddxBlogCFCposts#"> 
<!--- <cffile action="read" file="#ExpandPath('./')#qBlogCFCposts.xml" variable="wddxBlogCFCposts">
<cfwddx action="wddx2cfml" input="#wddxBlogCFCposts#" output="qBlogCFCposts">  --->
<!--- <cfdump var="#qBlogCFCposts#">  --->

<!--- CATEGORY_POST MAPPING --->
<!--- do some tricky sql to get all the mappings (join catID and postID on the newIDs in the local objects) and then insert this query object into the WP post2Cat table --->
<cfinvoke component="Wordpress" method="JoinAndInsertCatMappings" returnvariable="numberOfMappingsCreated">
	<cfinvokeargument name="qBlogCFCcats" value="#qBlogCFCcats#">
	<cfinvokeargument name="qBlogCFCposts" value="#qBlogCFCposts#">
</cfinvoke>  
<!--- update the category count field (why are they storing this derived value in the db anyways??) --->
<cfinvoke component="Wordpress" method="updateCategoryCount" returnvariable="bleh"/> 
<li>NUM CATMAPPINGS ADDED: <cfoutput>#numberOfMappingsCreated#</cfoutput></li><cfflush> 
	
<!--- COMMENTS --->
<!--- add all the BlogCFC comments --->
<cfinvoke component="BlogCFC" method="getAllComments" returnvariable="qallComments"/>
<cfinvoke component="Wordpress" method="insertAllComments" returnvariable="numberOfComments">
	<cfinvokeargument name="qallComments" value="#qallComments#">
	<cfinvokeargument name="qBlogCFCposts" value="#qBlogCFCposts#">
</cfinvoke>  
<cfinvoke component="Wordpress" method="updateCommentCount" returnvariable="numberOfComments"/>

<li>NUM COMMENTS ADDED: <cfoutput>#numberOfComments#</cfoutput></li><cfflush>

You're all set. If you want to keep legacy links and existing readers, move the following files: index.cfm, rss.cfm and qBlogCFCposts.xml, config.ini  into your Wordpress root dir. Make sure you delete this directory when finished if it's publicly-accessible and promote your index.php document above your index.cfm in preference on your webserver. 
<br><br>
Like building cool stuff in your spare time?  Consider joining the <a href="http://www.grid7.com/labs">Grid7 Labs</a> team.