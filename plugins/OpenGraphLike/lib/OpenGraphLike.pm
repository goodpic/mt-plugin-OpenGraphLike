package OpenGraphLike;

use strict;
use utf8;
use warnings;
use MT::Util qw( remove_html );
# use Data::Dumper;

sub _get_params {
    my ($ctx, $args, $cond) = @_;
    my %params;
    $params{'blog'}   = $ctx->stash('blog') or return '';
    $params{'config'} = MT->component("OpenGraphLike")->get_config_hash("blog:" . $params{'blog'}->id);
    $params{'entry'} = $ctx->stash('entry');
    $params{'data'}  = {
        'og:title'       => $params{'blog'}->name,
        'og:site_name'   => $params{'blog'}->name,
        'og:url'         => $params{'blog'}->site_url,
        'og:description' => $params{'blog'}->description,
        'og:type'        => 'article',
        'fb:admins'      => $params{'config'}->{'fb_admins'}
    };

    if ($params{'entry'}) {
        $params{'data'}{'og:url'}   = $params{'entry'}->permalink;
        $params{'data'}{'og:title'} = $params{'entry'}->title;
        $params{'data'}{'og:description'} = $params{'config'}->{fb_excerpt} ? $params{'entry'}->excerpt : $params{'entry'}->text;
    }
    # remove html, new line chars and "
    $params{'data'}{'og:description'} = substr( remove_html($params{'data'}{'og:description'}), 0, 200);
    $params{'data'}{'og:description'} =~ tr/\x0D\x0A\"//d;

    return %params;
}


sub _hdlr_opengraph_meta {
    my %params = &_get_params(@_);
    return &_get_opengraph_meta(%params);
}
sub _get_opengraph_meta {
    my %params = @_;
    my $meta = '';
    while ( my ($key, $value) = each %{$params{'data'}} ) {
        $meta .= '<meta property="' . $key . '" content="' . $value . '"/>';
    }
    
    # Add og:image for assets
    if ($params{'entry'}) {
        use MT::Asset;
        use MT::ObjectAsset;
        my @assets = MT::Asset->load({ class => 'image'}, {
            join => MT::ObjectAsset->join_on(
                'asset_id',{ object_ds => MT::Entry->datasource, object_id => $params{'entry'}->id})
        });
        for my $asset (@assets) {
            $meta .= '<meta property="og:image" content="'. $asset->url  . '"/>';
        }
    }
    $meta .= '<script type="text/javascript" src="https://apis.google.com/js/plusone.js">'
        .  "{lang: '" . $params{'config'}{'og_lang'} . "'}</script>";
    return $meta;
}


sub _hdlr_facebook_button {
    my %params = &_get_params(@_);
    return &_get_facebook_button(%params);
}
sub _get_facebook_button {
    my %params = @_;
    
    my $show_faces = "false";
    my $send       = "false";
    my $height     = 35;
    if ($params{'config'}{'fb_layout'} eq "button_count") {
        $height = 21;
    } elsif ($params{'config'}{'fb_layout'} eq "box_count") {
        $height = 90;
    }

    if ( $params{'config'}{'fb_send'} )  { $send = "true";}
    if ( $params{'config'}{'fb_faces'} ) {
        $show_faces = "true";
        unless ($params{'config'}{'fb_layout'} eq "button_count") { $height = 80;}
    }
    my $like = '<iframe src="http://www.facebook.com/plugins/like.php?href='
         .  MT::Util::encode_url($params{'data'}{'og:url'})
         . '&amp;layout='      . $params{'config'}{'fb_layout'}
         . '&amp;show_faces='  . $show_faces
         . '&amp;send='        . $send
         . '&amp;width='       . $params{'config'}{'fb_width'}
         . '&amp;height='      . $height
         . '&amp;action='      . $params{'config'}{'fb_verb'}
         . '&amp;font='        . $params{'config'}{'fb_font'}
         . '&amp;colorscheme=' . $params{'config'}{'fb_color'}
         . '" scrolling="no" frameborder="0" style="border:none; overflow:hidden; '
         . 'width:'        . $params{'config'}{'fb_width'}
         . 'px; height: '    . $height . 'px;" allowTransparency="true"></iframe>';
    return $like;
}

sub _hdlr_google_button {
    my %params = &_get_params(@_);
    return &_get_google_button(%params);
}
sub _get_google_button {
    my %params = @_;
    
    my $button = "<g:plusone ";
    if ($params{'config'}{'og_google_callback'}) {
        $button .= ' callback="' . $params{'config'}{'og_google_callback'} . '" ';
    }
    if (!$params{'config'}{'og_google_count'}) {
        $button .= ' count="false" ';
    }
    if ($params{'config'}{'og_google_size'} ne "standard") {
        $button .= ' size="' . $params{'config'}{'og_google_size'} . '" ';
    }
    $button .= 'href="' . $params{'data'}{'og:url'} . '"></g:plusone>';
    return $button;
}

sub _hdlr_tweet_button {
    my %params = &_get_params(@_);
    return &_get_tweet_button(%params);
}
sub _get_tweet_button {
    my %params = @_;    

    my $button = '<a href="http://twitter.com/share" class="twitter-share-button" data-lang="' . $params{'config'}{'og_lang'}  . '" data-url="' . $params{'data'}{'og:url'} . '"';
    if ($params{'config'}{'og_tweet_size'}) {
        $button .= ' data-count="'. $params{'config'}{'og_tweet_size'} . '" ';
    }
    if ($params{'config'}{'og_tweet_user'}) {
        $button .= ' data-via="' . $params{'config'}{'og_tweet_user'} . '" ';
    }
    $button .= '>Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>';
    return $button;
}

sub _hdlr_tumblr_js {
    my %params = &_get_params(@_);
    return &_get_tumblr_js(%params);
}
sub _get_tumblr_js {
    my %params = @_;    

    my $width = "20px";
    if ( index($params{'config'}{'og_tmblr_size'},"_1")) { $width = "81px";}
    return <<EOD;
<script type="text/javascript">
    var tumblr_link_url = "$params{'data'}{'og:url'}";
    var tumblr_link_name = "$params{'data'}{'og:title'}";
    var tumblr_link_description = "$params{'data'}{'og:description'}";
</script>

<!-- Put this code at the bottom of your page -->
<script type="text/javascript">
    var tumblr_button = document.createElement("a");
    tumblr_button.setAttribute("href", "http://www.tumblr.com/share/link?url=" + encodeURIComponent(tumblr_link_url) + "&name=" + encodeURIComponent(tumblr_link_name) + "&description=" + encodeURIComponent(tumblr_link_description));
    tumblr_button.setAttribute("title", "Share on Tumblr");
    tumblr_button.setAttribute("style", "display:inline-block; text-indent:-9999px; overflow:hidden; height:20px; width: $width; background:url('http://platform.tumblr.com/v1/$params{'config'}{'og_tumblr_size'}.png') top left no-repeat transparent;");
    tumblr_button.innerHTML = "Share on Tumblr";
    document.getElementById("tumblr_button_abc123").appendChild(tumblr_button);
</script>
EOD
}

sub _hdlr_tumblr_button {
    return '<span id="tumblr_button_abc123"></span>';
}

sub _hdlr_evernote_button {
    my %params = &_get_params(@_);
    return &_get_evernote_button(%params);
}
sub _get_evernote_button {
    my %params = @_;    
    return <<EOD;
<script type="text/javascript" src="http://static.evernote.com/noteit.js"></script>
<a href="#" onclick="Evernote.doClip({contentId:'$params{'config'}{'og_evernote_id'}',providerName:'$params{'data'}{'og:title'}',suggestNotebook:'$params{'config'}{'og_evernote_book'}',code:'$params{'config'}{'og_evernote_code'}'}); return false;"><img src="http://static.evernote.com/$params{'config'}{'og_evernote_size'}.png" alt="Clip to Evernote" /></a>
EOD
}

sub _hdlr_hatena_button {
    my %params = &_get_params(@_);
    return &_get_hatena_button(%params);
}
sub _get_hatena_button {
    my %params = @_;    
    my $button = '<a href="http://b.hatena.ne.jp/entry/'
        . $params{'data'}{'og:url'} . '" class="hatena-bookmark-button" data-hatena-bookmark-title="'
        . $params{'data'}{'og:title'} . '" data-hatena-bookmark-layout="'
        . $params{'config'}{'og_hatena_size'} . '" title="このエントリーをはてなブックマークに追加"><img src="http://b.st-hatena.com/images/entry-button/button-only.gif" alt="このエントリーをはてなブックマークに追加" width="20" height="20" style="border: none;" /></a><script type="text/javascript" src="http://b.st-hatena.com/js/bookmark_button.js" charset="utf-8" async="async"></script>';
    return $button;
}

sub _hdlr_mixi_button {
    my %params = &_get_params(@_);
    return &_get_mixi_button(%params);
}
sub _get_mixi_button {
    my %params = @_;    
    return <<EOF
<a href="http://mixi.jp/share.pl" class="mixi-check-button" data-key="$params{'config'}{'og_mixi_key'}" data-url="$params{'data'}{'og:url'}" data-button="button-3">Check</a><script type="text/javascript" src="http://static.mixi.jp/js/share.js"></script>
EOF
}

sub _hdlr_gree_button {
    my %params = &_get_params(@_);
    return &_get_gree_button(%params);
}
sub _get_gree_button {
    my %params = @_;    
    return <<EOF
    <iframe src="http://share.gree.jp/share?url=$params{'data'}{'og:url'}&type=0&height=$params{'config'}{'og_gree_size'}" scrolling="no" frameborder="0" marginwidth="0" marginheight="0" style="border:none; overflow:hidden; width:100px; height: $params{'config'}{'og_gree_size'}px;" allowTransparency="true"></iframe>
EOF
        # return Dumper(\%params);
}

sub _hdlr_like_buttons {
    my %params = &_get_params(@_);

    return &_get_facebook_button(%params)
            . &_get_google_button(%params)
            . &_get_tweet_button(%params)
            . &_get_evernote_button(%params)
            . &_get_hatena_button(%params)
            . &_hdlr_tumblr_button()
            . &_get_mixi_button(%params)
            . &_get_gree_button(%params);
}

1;
