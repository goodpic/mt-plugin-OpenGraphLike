# Facebook Like plugin for Movable Type
# Author: Jun Kaneko
# Copyright 2010 Six Apart, Ltd.
# License: licensed under the same terms as Perl itself


OVERVIEW

This plugin adds MT tags to display Facebook Like button.
The Like button lets a user share your content with friends on Facebook.
When the user clicks the Like button on your site, a story appears in
the user's friends' News Feed with a link back to your website.

PREREQUISITES

- Movable Type 5.0 or higher

INSTALLATION

  1. Unpack the FacebookLike package.
  2. Copy the contents of FacebookLike/plugins into /path/to/mt/plugins/
  3. Select "Tools > Plugins" menu in your blog.
  4. Configure the plugin's settings
  5. Insert <$MTOpenGraphMeta$> in your HTML header (<head>) section.
  6. Insert <$MTFaceBookLike$>  in the section
     where you wish to display the "Like" button.


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

  This template tag will publish the IFRAME HTML to display the Like button.
  http://developers.facebook.com/docs/reference/plugins/like

CHANGES

0.2  2010.Aug.26 Bug Fix for word counting.
0.1  2010.Aug.26 Initial release.

AUTHOR

Jun Kaneko kaneko@gmail.com

COPYRIGHT AND LICENSE

Copyright (C) 2010 Six Apart, Ltd.

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl 5.10.0. 

This program is distributed in the hope that it will be
useful, but without any warranty; without even the implied
warranty of merchantability or fitness for a particular purpose.
