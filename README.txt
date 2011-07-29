# OpenGraph Like plugin for Movable Type
# Author: Jun Kaneko
# License: licensed under the same terms as Perl itself


OVERVIEW

This plugin adds MT tags to display various social buttons such
as Facebook Like, Google Plus, Tweet, Evernote Clip, Tumblr, mixi,
and gree button.
The Like button lets a user share your content on social networks.
When the user clicks the Like button on your site, a story appears
in the user's friends' News Feed with a link back to your website.
This plugin supports both static and dynamic publishing.

PREREQUISITES

- Movable Type 5.0 or higher

INSTALLATION

  1. Unpack the OpenGraphLike package.
  2. Copy the contents of OpenGraphLike/plugins into /path/to/mt/plugins/
  3. Select "Tools > Plugins" menu in your blog.
  4. Configure the plugin's settings
  5. Insert <$MTOpenGraphMeta$> in your HTML header (<head>) section.
  6. Insert following social button tags where you wish to show the button.
     If you use tumblr button, you need to paste <$MTTumblrJS$> to your
     html footer area.


TEMPLATE CODE

  <$MTOpenGraphMeta$>

  This template tag will publish the following OpenGraph meta tags.

  <meta property="og:site_name" content=""/>
  <meta property="og:title" content=""/> 
  <meta property="og:type" content="article"/> 
  <meta property="og:url" content=""/> 
  <meta property="og:description" content=""/> 
  <meta property="fb:admins" content=""/> 
  <meta property="og:image" content=""/>

  Please refer to the following page for more detail.
  http://developers.facebook.com/docs/opengraph

  <$MTFaceBookLike$>
  <$MTFaceBookLike$>
  <$MTEvernoteButton$>
  <$MTTumblrJS$> , <$MTTumblrButton$>
  <$MTTweetButton$>
  <$MTHatenaBookmarkButton$>
  <$MTGreeButton$>
  <$MTGooglePlusButton$>
  <$MTMixiButton$>

  See the following developer's guides about technical details.

  http://developers.facebook.com/docs/reference/plugins/like
  http://twitter.com/about/resources/tweetbutton
  http://www.tumblr.com/docs/ja/share_button
  http://www.evernote.com/about/intl/jp/developer/sitememory/
  http://developer.gree.co.jp/connect/plugins/sf
  http://developer.mixi.co.jp/connect/mixi_plugin/mixi_check/
  

CHANGES

1.0  2011.Jul.28 Support Google+,Tweet,Evernote,Tumblr,and etc
0.2  2010.Aug.26 Bug Fix for word counting.
0.1  2010.Aug.26 Initial release.

AUTHOR

Jun Kaneko kaneko@gmail.com

COPYRIGHT AND LICENSE

Copyright (C) 2011 Jun Kaneko

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl 5.10.0. 

This program is distributed in the hope that it will be
useful, but without any warranty; without even the implied
warranty of merchantability or fitness for a particular purpose.
