<cfapplication name="BlocCFC2WP">
<cfset configFile = expandPath("./config.ini")>
<!--- setup environment variables --->
<cfscript>
	application.blogCFC = structNew();
	application.blogCFC.datasource = getProfileString(configFile, "blogcfc", "ds");
	application.wordPress = structNew();
	application.wordPress.datasource = getProfileString(configFile, "wordpress", "ds");
	application.wordPress.pfx = getProfileString(configFile, "wordpress", "dbPrefix");
	application.wordPress.gmtOffset = getProfileString(configFile, "wordpress", "gmtOffset");
</cfscript>

<cfif application.wordPress.datasource eq "your_wordpress_DSN" or application.blogCFC.datasource eq "your_blogcfc_DSN">You need to add the datasources to the config.ini file.<cfabort></cfif>