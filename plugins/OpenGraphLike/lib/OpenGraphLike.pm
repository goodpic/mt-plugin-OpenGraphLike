package OpenGraphLike;

use strict;
use utf8;
use warnings;

sub _hdlr_opengraph_meta {
    my ($ctx, $args, $cond) = @_;
    my $plugin    = MT->component("OpenGraphLike");
    my $blog      = $ctx->stash('blog') or return '';
    my $config    = $plugin->get_config_hash("blog:" . $blog->id);

    my $entry     = $ctx->stash('entry');
    my $url       = $entry ? $entry->permalink : $blog->site_url;
    my $title     = $entry ? $entry->title : $blog->name;

    my $description = $blog->description;
    my $assets_str;
    if ($entry) {
        $description = $config->{fb_excerpt} ? $entry->excerpt : $entry->text;
        use MT::Asset;
        use MT::ObjectAsset;
        my @assets = MT::Asset->load({ class => 'image'}, {
            join => MT::ObjectAsset->join_on(
                'asset_id',{ object_ds => MT::Entry->datasource, object_id => $entry->id})
        });
        for my $asset (@assets) {
            $assets_str .= '<meta property="og:image" content="'. $asset->url  . '"/>';
        }
    }
    $description = MT::Util::first_n_words($description,150);

    my $meta = '<meta property="og:site_name" content="' . $blog->name . '"/>';
    $meta .=<<"EOF";
<meta property="og:title" content="$title"/>
<meta property="og:type" content="article"/>
<meta property="og:url" content="$url"/>
<meta property="og:description" content="$description"/>
<meta property="fb:admins" content="$config->{'fb_admins'}"/>
$assets_str
EOF
    return $meta;
}

sub _hdlr_facebook_like {
    my ($ctx, $args, $cond) = @_;
    my $plugin    = MT->component("OpenGraphLike");
    my $blog      = $ctx->stash('blog') or return '';
    my $config    = $plugin->get_config_hash("blog:" . $blog->id);
    
    my $entry     = $ctx->stash('entry');    
    my $url       = $entry ? $entry->permalink : $blog->site_url;

    my $show_faces = "false";
    my $height    = $config->{'fb_layout'} eq "button_count" ? 21 : 35;
    if ( $config->{'fb_faces'} ) {
        $show_faces = "true";
        unless ($config->{'fb_layout'} eq "button_count") { $height = 80;}
    }

    my $like = '<iframe src="http://www.facebook.com/plugins/like.php?href='
         .  MT::Util::encode_url($url)
         . '&amp;layout='      . $config->{'fb_layout'}
         . '&amp;show_faces='  . $show_faces
         . '&amp;width='       . $config->{'fb_width'}
         . '&amp;action='      . $config->{'fb_verb'}
         . '&amp;font='        . $config->{'fb_font'}
         . '&amp;colorscheme=' . $config->{'fb_color'}
         . '&amp;height='      . $height
         . '" scrolling="no" frameborder="0" style="border:none; overflow:hidden; '
         . 'width:'            . $config->{'fb_width'}
         . '; height: '        . $height . 'px;" allowTransparency="true"></iframe>';
    return $like;
}

1;
