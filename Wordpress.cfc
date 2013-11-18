<cfcomponent name="Wordpress">

	<cffunction name="init" access="remote" returnType="void" output="false" hint="Initialize the component">
		<cfset instance = structNew()>
		<cfinclude template="./application.cfm">
		<cfreturn this>
	</cffunction>

	<!--- ----------------------------------------------------------------------------------- --->
	<cffunction name="insertCategory" access="public" returntype="string" output="false"
		hint="I insert a new category into the WP db and return the new WPID">

		<cfargument name="catName" required="yes" type="string">
		<cfset var NewCatID = "">
		<!--- query the categories table --->
		<cfquery name="insertCategory" datasource="#application.Wordpress.datasource#">
			INSERT INTO #application.wordPress.pfx#terms
			(name,slug)
			values('#arguments.catname#','#LCASE(REReplaceNoCase(arguments.catname, '[^a-zA-Z]', '-','all'))#')
			</cfquery>

		<cfquery name="getNewCatID" datasource="#application.Wordpress.datasource#">
			SELECT Max(term_id) as newCatID FROM #application.wordPress.pfx#terms
			</cfquery>
		<cfset NewCatID = getNewCatID.newCatID>
		<cfreturn NewCatID>
	</cffunction>

	<!--- ----------------------------------------------------------------------------------- --->
	<cffunction name="insertPost" access="public" returntype="string" output="false"
		hint="I insert a new post into the WP db and return the new WPID">

		<cfargument name="postObj" required="yes" type="struct">
		<cfset var NewPostID = "">
		<cfset var localObj = arguments.postObj>
		<cfset var theDateTime = CreateODBCDateTime(localObj.posted)>

		<!--- insert into the post table --->
		<cfquery name="insertPost" datasource="#application.Wordpress.datasource#">
			INSERT INTO #application.wordPress.pfx#posts
			(
			  post_author
			, post_date
			, post_date_gmt
			, post_content
			, post_title
			, post_status
			, comment_status
			, ping_status
			, post_name
			, post_modified
			, post_modified_gmt

			)
			values(
			  1
			, #theDateTime#
			, #DateAdd("h", application.wordPress.gmtOffset, theDateTime)#
			, '#localObj.body#'
			, '#localObj.title#'
			, 'publish'
			, '#IIf(localObj.allowcomments EQ 1, DE("open"), DE("closed"))#'
			, 'open'
			, '#makeURLFriendlyName(localObj.title)#'
			, #theDateTime#
			, #DateAdd('h', application.wordPress.gmtOffset, theDateTime)#
			)
			</cfquery>

		<cfquery name="getNewPostID" datasource="#application.Wordpress.datasource#">
			SELECT Max(ID) as NewPostID FROM #application.wordPress.pfx#posts
			</cfquery>

		<cfset NewPostID = getNewPostID.NewPostID>
		<cfreturn NewPostID>
	</cffunction>

	<!--- ----------------------------------------------------------------------------------- --->
	<cffunction name="JoinAndInsertCatMappings" access="public" returntype="numeric" output="false"
		hint="I translate the ids from the old post/category mapping table to a new one and then insert it into the WP taxonomy relationship table.">

		<cfargument name="qBlogCFCcats" required="yes" type="query">
		<cfargument name="qBlogCFCposts" required="yes" type="query">
		<cfscript>
			var categories = arguments.qBlogCFCcats;
			var posts = arguments.qBlogCFCposts;
			var mappingCount = 0;
		</cfscript>

		<!--- get the mappings from blogcfc and stuff into a local query obj so we can do QofQ --->
		<cfquery name="MapTable" datasource="#application.BlogCFC.datasource#">
			SELECT * FROM tblblogentriescategories
		</cfquery>

		<!--- can't do triple join in QofQ so need to run back-to-back queries. first update the map table with the new ID for posts --->
		<cfquery name="MapTablePlusPosts" dbtype="query">
			SELECT NewWPPostID as post_id, CATEGORYIDFK
			FROM posts, MapTable
			WHERE posts.ID = MapTable.ENTRYIDFK
		</cfquery>

		<!--- now add in the new category id so we have the right query object that matches the WP map table --->
		<cfquery name="MapTableWithBoth" dbtype="query">
			SELECT NewWPCatID as category_id, post_id
			FROM categories, MapTablePlusPosts
			WHERE categories.categoryID = MapTablePlusPosts.CATEGORYIDFK
		</cfquery>

		<!--- now loop through all the records and insert them into the WP mapping table --->
		<cfloop query="MapTableWithBoth">
			<cfquery name="insertMapping" datasource="#application.Wordpress.datasource#">
				INSERT INTO #application.wordPress.pfx#term_relationships
				(object_id, term_taxonomy_id)
				VALUES (#post_id#,#category_id#)
			</cfquery>
			<cfset mappingCount = mappingCount + 1>

		</cfloop>

		<cfreturn mappingCount>
	</cffunction>

	<!--- ----------------------------------------------------------------------------------- --->
	<cffunction name="InsertWPCategoriesIntoRelationshipTable" access="public" returntype="void" output="false"
		hint="WP 3.5 and above has a different mapping scheme. For a category to be recognized, we need to insert the relationships.">

		<!--- Grab all the categories and insert them into the relationship table --->
			<cfquery name="InsertCatsIntoTermTaxonomy" datasource="#application.Wordpress.datasource#">
					SELECT term_id AS term_id_to_insert
					FROM #application.wordPress.pfx#terms
					WHERE term_id NOT IN (SELECT term_id FROM #application.wordPress.pfx#term_taxonomy)
				</cfquery>

		<!--- Do the inserting --->
			<cfloop query="InsertCatsIntoTermTaxonomy">

				<cfquery name="InsertCats" datasource="#application.Wordpress.datasource#">
						INSERT INTO #application.wordPress.pfx#term_taxonomy
						(term_id, taxonomy,description)
						VALUES(#term_id_to_insert#, 'category', '')
					</cfquery>

			</cfloop>

		<cfreturn>
	</cffunction>



	<!--- -----------------------------------------------------------------------------------
	<cffunction name="updateCategoryCount" access="public" returntype="void" output="false" hint="I update the category_count column in the categories table to reflect the number of ">
		<cfset var count = 0>
		<cfset var PostNumThisCategory = "">

		<!--- get the mappings from blogcfc and stuff into a local query obj so we can do QofQ --->
		<cfquery name="getAllMappings" datasource="#application.Wordpress.datasource#">
			SELECT * FROM #application.wordPress.pfx#term_relationships
		</cfquery>

		<!--- get all the categories --->
		<cfquery name="getAllCats" datasource="#application.Wordpress.datasource#">
			SELECT * FROM #application.wordPress.pfx#terms
			WHERE term_taxonomy_id = 1;
		</cfquery>

		<!--- loop through each category and update the count --->
		<cfloop query="getAllCats">
			<cfquery name="PostNumThisCategory" dbtype="query">
				SELECT term_id FROM getAllMappings
				WHERE  term_taxonomy_id= #term_taxonomy_id#
			</cfquery>
			<cfquery name="UpdateCount" datasource="#application.Wordpress.datasource#">
				UPDATE #application.wordPress.pfx#posts
				SET category_count = #PostNumThisCategory.recordcount#
				WHERE  cat_id= #cat_id#
			</cfquery>

		</cfloop>
		<cfreturn>
	</cffunction>
 --->

	<!--- ----------------------------------------------------------------------------------- --->
	<cffunction name="insertAllComments" access="public" returntype="numeric" output="false" hint="I insert all the comments from BlogCFC using the new WP ids">
		<cfargument name="qallComments" required="yes" type="query">
		<cfargument name="qBlogCFCposts" required="yes" type="query">
		<cfscript>
			var count = 0;
			var comments = arguments.qallComments;
			var posts = arguments.qBlogCFCposts;
		</cfscript>
		<cfquery name="MergeNewPostIDtoComments" dbtype="query">
			SELECT comments.*, posts.newwppostid
			FROM comments, posts
			WHERE comments.ENTRYIDFK = posts.id
		</cfquery>

		<!--- insert the comments --->
		<cfloop query="MergeNewPostIDtoComments">
			<cfquery name="insertComment" datasource="#application.Wordpress.datasource#">
				INSERT INTO #application.wordPress.pfx#comments
				(comment_post_ID,comment_author,comment_author_email,comment_date,comment_date_gmt,comment_content,comment_approved)
				values(
				#NEWWPPOSTID#,
				'#NAME#',
				'#EMAIL#',
				#CreateODBCDateTime(posted)#,
				#DateAdd("h", application.wordPress.gmtOffset, CreateODBCDateTime(posted))#,
				'#COMMENT#',
				'1'
				)
			</cfquery>
		</cfloop>
		<cfreturn MergeNewPostIDtoComments.recordcount>
	</cffunction>

	<!--- ----------------------------------------------------------------------------------- --->
	<cffunction name="updateCommentCount" access="public" returntype="numeric" output="false" hint="I update the comment_count column in the categories table to reflect the number of ">
		<cfscript>
			var count = 0;
			var CommentNumThisPost = "";
		</cfscript>
		<cfquery name="posts" datasource="#application.Wordpress.datasource#">
			SELECT ID FROM #application.wordPress.pfx#posts
		</cfquery>

		<!--- loop through each post and update the count --->
		<cfloop query="posts">
			<cfquery name="CommentNumThisPost" datasource="#application.Wordpress.datasource#">
				SELECT comment_id FROM #application.wordPress.pfx#comments
				WHERE  comment_post_id = #id#
			</cfquery>
			<cfquery name="UpdateCount" datasource="#application.Wordpress.datasource#">
				UPDATE #application.wordPress.pfx#posts
				SET comment_count = #CommentNumThisPost.recordcount#
				WHERE  id= #id#
			</cfquery>
		</cfloop>
		<cfreturn posts.recordcount>
	</cffunction>

	<!--- ----------------------------------------------------------------------------------- --->
	<cffunction name="makeURLFriendlyName" access="public" returntype="string" output="false" hint="I take an ugly title with weird chars and make it lowercase and substitute in hyphens for spaces.">
		<cfargument name="UglyTitle" required="yes" type="string">
		<cfscript>
			var NewTitle = arguments.UglyTitle;
			//strip out weird chars
			NewTitle = REReplace(NewTitle, "[[:punct:]]", "", "ALL");
			//substitute hyphens for spaces
			NewTitle = REReplace(NewTitle, "[[:space:]]", "-", "ALL");
			//lowercase everything
			NewTitle = lcase(NewTitle);
		</cfscript>
		<cfreturn NewTitle>
	</cffunction>
</cfcomponent>
