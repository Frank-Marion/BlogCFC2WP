<cffunction name="makeURLFriendlyName" access="public" returntype="string" output="false" hint="I take an ugly title with weird chars and make it lowercase and substitute in hyphens for spaces.">
	<cfargument name="UglyTitle" required="yes" type="string">
	<cfscript>
		var NewTitle = arguments.UglyTitle;
		//strip out weird chars
		NewTitle = REReplace(NewTitle, "[[:punct:]]", "", "ALL");
		//substitute hyphens for spaces
		NewTitle = REReplace(NewTitle, "[[:space:]]", "-", "ALL");
		//replace multiple dashes with a single dash
		NewTitle = REReplace(NewTitle, "-{2,}", "-", "ALL");
		//lowercase everything
		NewTitle = lcase(NewTitle);
	</cfscript>
	<cfreturn NewTitle>
</cffunction>

<cfquery name="grabAllPubArticles" datasource="bigbooksponsorship">
SELECT
  articles.ArticleID
, articles.ArticleTitle
, articles.ArticleBody
, articles.DateCreated
, articles.DateModified
, articles.ArticleDescription
FROM articles;
</cfquery>


<cfloop query="grabAllPubArticles">
	<cfoutput>
		<!---
	<tr>
		<td valign="top">1</td>
		<td valign="top">#DateCreated#</td>
		<td valign="top">#DateAdd("h", '-5', DateCreated)#</td>
		<td valign="top">'#ArticleBody#'</td>
		<td valign="top">'#ArticleTitle#'</td>
		<td valign="top">'publish'</td>
		<td valign="top">'1'</td>
		<td valign="top">'open'</td>
		<td valign="top">'#makeURLFriendlyName(ArticleTitle)#'</td>
		<td valign="top">#DateModified#</td>
		<td valign="top">#DateAdd("h", '-5', DateModified)#</td>
		<td valign="top">'page'</td>
	</tr> --->
	</cfoutput>

	<cfquery name="InsertInsertIntoWP" datasource="wp_bigbook">
			INSERT INTO wp_posts
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
			, post_type
			)
			values(
			  1
			, {ts '#DateCreated#'}
			, #DateAdd("h", '-5', DateCreated)#
			, '#ArticleBody#'
			, '#ArticleTitle#'
			, 'publish'
			, '1'
			, 'open'
			, '#makeURLFriendlyName(ArticleTitle)#'
			, {ts '#DateModified#'}
			, #DateAdd("h", '-5', DateModified)#
			, 'page'
			)
	</cfquery>

	<cfflush>
</cfloop>

