This utility will migrate your data from a BlogCFC db into an existing Wordpress 2.0 db.  It has been tested on CFMX7 and BlueDragon 6.2 running on Windows against a MySQL 4 db and BlogCFC v. 3.8.  The schema for v.5 of BlogCFC has some new fields added but it doesn't look significantly different so it will probably work with minor modification. All the logic is contained in cfc's and there is no funky sql syntax or stored procs so it should work with other databases.  This is what you do to make it work:


1. Download the latest Wordpress installer and setup a new instance of Wordpress on your server (I'm assuming you have PHP and CF running on the same machine).

2. Make sure you have the permalink structure the way you want it for your new WP instance (the script will generate a legacyLinks file mapping based on this). 

3. Configure a datasource in CF administrator for your new Wordpress db. You should already have one set up for your BlogCFC db.

4. Extract the files to a directory on your site

5. Modify the config.ini file to reflect both datasources and table prefix and GMT offset if they are different from default 

6. Provided you want a fresh install you should clear out the dummy data that comes with your WP install. just run a "Delete from [wp_categories,wp_comments,wp_post2cat,wp_posts]. I didn't put this in the script because I didn't want to blow away records in a WP instance automatically in case it's not a new install.

7. Run the RunMe.cfm file in a browser

8. Two optional last steps:
  a. put the rss.cfm file in the root of your wordpress blog and redirect it to the location of your new feed (usually /index.php?feed=rss2). This will allow you to keep all your old subscribers
  b. put the index.cfm and qBlogCFCPosts.xml files in your root to handle redirects for all your old links 

That's it. Let me know if it you make it work in other environments. This code is AS-IS and I'm not supporting it. Feel free to tweak it, redistribute it, whatever. I hope it helps. If you find it valuable, buy me a book off the amazon wishlist linked from my blog (http://www.scrollinondubs.com).  Props to Ray and Matt for two pieces of great blog software.
Sean Tierney
sean@grid7.com


