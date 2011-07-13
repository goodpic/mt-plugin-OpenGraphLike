package OpenGraphLike;

use strict;
use utf8;
use warnings;
use Data::Dumper;
use MT::Util qw( remove_html );

sub _get_og {
    my ($blog, $entry, $config) = @_;
    my %og   = (
        'og:title'       => $blog->name,
        'og:site_name'   => $blog->name,
        'og:url'         => $blog->site_url,
        'og:description' => $blog->description,
        'og:type'        => 'article',
        'fb:admins'      => $config->{'fb_admins'}
    );

    if ($entry) {
        $og{'og:url'}   = $entry->permalink;
        $og{'og:title'} = $entry->title;
        $og{'og:description'} = $config->{fb_excerpt} ? $entry->excerpt : $entry->text;
    }
    # remove html, new line chars and "
    $og{'og:description'} = substr( remove_html($og{'og:description'}), 0, 200);
    $og{'og:description'} =~ tr/\x0D\x0A\"//d;

    return %og;
}

sub _hdlr_opengraph_meta {
    my ($ctx, $args, $cond) = @_;
    my $blog = $ctx->stash('blog') or return '';
    my $config    = MT->component("OpenGraphLike")->get_config_hash("blog:" . $blog->id);
    my $entry  = $ctx->stash('entry');
    
    my %og   = &_get_og($blog, $entry, $config);
    my $meta = '';
    while ( my ($key, $value) = each %og ) {
        $meta .= '<meta property="' . $key . '" content="' . $value . '"/>';
    }
    
    # Add og:image for assets
    if ($entry) {
        use MT::Asset;
        use MT::ObjectAsset;
        my @assets = MT::Asset->load({ class => 'image'}, {
            join => MT::ObjectAsset->join_on(
                'asset_id',{ object_ds => MT::Entry->datasource, object_id => $entry->id})
        });
        for my $asset (@assets) {
            $meta .= '<meta property="og:image" content="'. $asset->url  . '"/>';
        }
    }
    $meta .= '<script type="text/javascript" src="https://apis.google.com/js/plusone.js">'
        .  "{lang: '" . $config->{'og_lang'} . "'}</script>";
    return $meta;
}


sub _hdlr_facebook_button {
    my ($ctx, $args, $cond) = @_;
    my $blog      = $ctx->stash('blog') or return '';
    my $config    = MT->component("OpenGraphLike")->get_config_hash("blog:" . $blog->id);
    
    my $entry     = $ctx->stash('entry');
    my %og   = &_get_og($blog, $entry, $config);

    my $show_faces = "false";
    my $height    = $config->{'fb_layout'} eq "button_count" ? 21 : 35;
    
    if ( $config->{'fb_faces'} ) {
        $show_faces = "true";
        unless ($config->{'fb_layout'} eq "button_count") { $height = 80;}
    }
    my $like = '<iframe src="http://www.facebook.com/plugins/like.php?href='
         .  MT::Util::encode_url($og{'og:url'})
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

sub _hdlr_google_button {
    my ($ctx, $args, $cond) = @_;
    my $blog      = $ctx->stash('blog') or return '';
    my $config    = MT->component("OpenGraphLike")->get_config_hash("blog:" . $blog->id);
    my $entry     = $ctx->stash('entry');
    my %og   = &_get_og($blog, $entry, $config);
    
    my $button = "<g:plusone ";
    if ($config->{'og_google_callback'}) {
        $button .= ' callback="' . $config->{'og_google_callback'} . '" ';
    }
    if (!$config->{'og_google_count'}) {
        $button .= ' count="false" ';
    }
    if ($config->{'og_google_size'} ne "standard") {
        $button .= ' size="' . $config->{'og_google_size'} . '" ';
    }
    $button .= 'href="' . $og{'og:url'} . '"></g:plusone>';
    return $button;
}

sub _hdlr_tweet_button {
    my ($ctx, $args, $cond) = @_;
    my $blog      = $ctx->stash('blog') or return '';
    my $config    = MT->component("OpenGraphLike")->get_config_hash("blog:" . $blog->id);
    my $entry     = $ctx->stash('entry');
    my %og   = &_get_og($blog, $entry, $config);
    my $button = '<a href="http://twitter.com/share" class="twitter-share-button" data-lang="' . $config->{'og_lang'}  . '" data-url="' . $og{'og:url'} . '"';
    if ($config->{'og_tweet_size'}) {
        $button .= ' data-count="'. $config->{'og_tweet_size'} . '" ';
    }
    if ($config->{'og_tweet_user'}) {
        $button .= ' data-via="' . $config->{'og_tweet_user'} . '" ';
    }
    $button .= '>Tweet</a>';
    $button .= '<script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>';
    return $button;
}

sub _hdlr_tumblr_js {
    my ($ctx, $args, $cond) = @_;
    my $blog      = $ctx->stash('blog') or return '';
    my $config    = MT->component("OpenGraphLike")->get_config_hash("blog:" . $blog->id);
    my $entry     = $ctx->stash('entry');
    my %og   = &_get_og($blog, $entry, $config);
    my $width = "20px";
    if ( index($config->{'og_tmblr_size'},"_1")) { $width = "81px";}
    my $button =<<"EOF";
<script type="text/javascript">
    var tumblr_link_url = "$og{'og:url'}";
    var tumblr_link_name = "$og{'og:title'}";
    var tumblr_link_description = "$og{'og:description'}";
</script>

<!-- Put this code at the bottom of your page -->
<script type="text/javascript">
    var tumblr_button = document.createElement("a");
    tumblr_button.setAttribute("href", "http://www.tumblr.com/share/link?url=" + encodeURIComponent(tumblr_link_url) + "&name=" + encodeURIComponent(tumblr_link_name) + "&description=" + encodeURIComponent(tumblr_link_description));
    tumblr_button.setAttribute("title", "Share on Tumblr");
    tumblr_button.setAttribute("style", "display:inline-block; text-indent:-9999px; overflow:hidden; height:20px; width: $width; background:url('http://platform.tumblr.com/v1/$config->{'og_tumblr_size'}.png') top left no-repeat transparent;");
    tumblr_button.innerHTML = "Share on Tumblr";
    document.getElementById("tumblr_button_abc123").appendChild(tumblr_button);
</script>
EOF
    return $button;
}

sub _hdlr_tumblr_button {
    return '<span id="tumblr_button_abc123"></span>';
}

sub _hdlr_evernote_button {
    my ($ctx, $args, $cond) = @_;
    my $blog      = $ctx->stash('blog') or return '';
    my $config    = MT->component("OpenGraphLike")->get_config_hash("blog:" . $blog->id);
    my $entry     = $ctx->stash('entry');
    my %og   = &_get_og($blog, $entry, $config);
    my $button =<<"EOF";
<script type="text/javascript" src="http://static.evernote.com/noteit.js"></script>
<a href="#" onclick="Evernote.doClip({contentId:'$config->{'og_evernote_id'}',providerName:'$og{'og:title'}',suggestNotebook:'$config->{'og_evernote_book'}',code:'$config->{'og_evernote_code'}'}); return false;"><img src="http://static.evernote.com/$config->{'og_evernote_size'}.png" alt="Clip to Evernote" /></a>
EOF
    # $button .= Dumper(\$config);
    return $button;
}

sub _hdlr_hatena_button {
    my ($ctx, $args, $cond) = @_;
    my $blog      = $ctx->stash('blog') or return '';
    my $config    = MT->component("OpenGraphLike")->get_config_hash("blog:" . $blog->id);
    my $entry     = $ctx->stash('entry');
    my %og   = &_get_og($blog, $entry, $config);
    my $button = '<a href="http://b.hatena.ne.jp/entry/'
        . $og{'og:url'} . '" class="hatena-bookmark-button" data-hatena-bookmark-title="'
        . $og{'og:title'} . '" data-hatena-bookmark-layout="'
        . $config->{'og_hatena_size'} . '" title="このエントリーをはてなブックマークに追加"><img src="http://b.st-hatena.com/images/entry-button/button-only.gif" alt="このエントリーをはてなブックマークに追加" width="20" height="20" style="border: none;" /></a><script type="text/javascript" src="http://b.st-hatena.com/js/bookmark_button.js" charset="utf-8" async="async"></script>';
    return $button;
}

sub _hdlr_mixi_button {
    my ($ctx, $args, $cond) = @_;
    my $blog      = $ctx->stash('blog') or return '';
    my $config    = MT->component("OpenGraphLike")->get_config_hash("blog:" . $blog->id);
    my $entry     = $ctx->stash('entry');
    my %og   = &_get_og($blog, $entry, $config);

    my $button  = '<a href="http://mixi.jp/share.pl" class="mixi-check-button" '
        . ' data-key="' . $config->{'og_mixi_key'}  . '" '
        . ' data-url="' . $og{'og:url'} . '" '
        . ' data-button="button-3" '
        . '>Check</a><script type="text/javascript" src="http://static.mixi.jp/js/share.js"></script>';
    return $button;
}

sub _hdlr_gree_button {
    my ($ctx, $args, $cond) = @_;
    my $blog      = $ctx->stash('blog') or return '';
    my $config    = MT->component("OpenGraphLike")->get_config_hash("blog:" . $blog->id);
    my $entry     = $ctx->stash('entry');
    my %og   = &_get_og($blog, $entry, $config);
    my $button = '<iframe src="http://share.gree.jp/share?url='
        . $og{'og:url'}  . '&type=0&height=' . $config->{'og_gree_size'}  . '" scrolling="no" frameborder="0" marginwidth="0" marginheight="0" style="border:none; overflow:hidden; width:100px; height:' . $config->{'og_gree_size'} . 'px;" allowTransparency="true"></iframe>';
    return $button;
}

1;
