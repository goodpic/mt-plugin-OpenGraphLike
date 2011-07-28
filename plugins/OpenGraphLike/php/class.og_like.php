<?php
class OGLike {
    protected $ogdata = array();
    protected $config = array();
    
    function __construct ($args, &$ctx) {
        require_once "function.mtentrypermalink.php";
        
        $id     = $ctx->stash('blog_id');
        $entry  = $ctx->stash('entry');
        $blog   = $ctx->stash('blog');
        $this->config = $ctx->mt->db()->fetch_plugin_data('OpenGraphLike', "configuration:blog:$id");
        
        if (!$blog) { return $ctx->error("Error : No blog");}        
        if ($entry) {
            $this->ogdata['url']   = smarty_function_mtentrypermalink($args, $ctx);
            $this->ogdata['title'] = strip_tags($entry->title);
            $this->ogdata['description'] = $this->config['fb_excerpt'] ? $entry->excerpt : $entry->text;
        } else {
            $this->ogdata['url']   = $blog->site_url();
            $this->ogdata['title'] = strip_tags($blog->name);
            $this->ogdata['description'] = $blog->description;
        }
        $this->ogdata['description'] = strip_tags($this->ogdata['description']);
        $this->ogdata['description'] = mb_substr($this->ogdata['description'],0,150);
    }

    public function _get_meta() {
        return <<<EOT
<meta property="og:type" content="article"/>
<meta property="og:title" content="{$this->ogdata['title']}" />
<meta property="og:description" content="{$this->ogdata['description']}" />
<meta property="og:url" content="{$this->ogdata['url']}"/>
EOT;
    }

    public function _get_facebooklike() {

        $show_faces = "false";
        $send       = "false";
        $height     = 35;
        if ($this->config['fb_layout'] === "button_count") {
            $height = 21;
        } elseif ($this->config['fb_layout'] === "box_count") {
            $height = 90;
        }

        if ( $this->config['fb_send'] )  { $send = "true";}
        if ( $this->config['fb_faces'] ) {
            $show_faces = "true";
            if ($this->config['fb_layout'] !== "button_count") { $height = 80;}
        }
        $url = urlencode($this->ogdata['url']);

        return <<<EOT
<iframe src="http://www.facebook.com/plugins/like.php?href={$url}&amp;layout={$this->config['fb_layout']}&amp;show_faces={$show_faces}&amp;send={$send}&amp;width={$this->config['fb_width']}&amp;height={$height}&amp;action={$this->config['fb_verb']}&amp;font={$this->config['fb_font']}&amp;colorscheme={$this->config['fb_color']}" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width: {$this->config['fb_width']}px; height: {$height}px;" allowTransparency="true"></iframe>
EOT;
    }
    
    public function _get_googleplus() {

        $button = "<g:plusone ";
        if ($this->config['og_google_callback']) {
            $button .= ' callback="' . $this->config['og_google_callback'] . '"';
        }
        if (!$this->config['og_google_count']) {
            $button .= ' count="false" ';
        }
        if ($this->config['og_google_size'] !== "standard") {
            $button .= ' size="' . $this->config['og_google_size'] . '"';
        }
        $button .= ' href="' . $this->ogdata['url'] . '"></g:plusone>';
    
        return $button;
    }
    
    public function _get_tweet() {

        $button = '<a href="http://twitter.com/share" class="twitter-share-button" data-lang="' . $this->config['og_lang']  . '" data-url="' . $this->ogdata['url'] . '"';
        if ($this->config['og_tweet_size']) {
            $button .= ' data-count="'. $this->config['og_tweet_size'] . '" ';
        }
        if ($this->config['og_tweet_user']) {
            $button .= ' data-via="' . $this->config['og_tweet_user'] . '" ';
        }
        $button .= '>Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>';
        return $button;
    }

    public function _get_tumblr() {
        return '<span id="tumblr_button_abc123"></span>';
    }

    public function _get_tumblrjs() {

        $width = "20px";
        if ( strpos($this->config['og_tmblr_size'],"_1")) { $width = "81px";}
        return <<<EOT
<script type="text/javascript">
    var tumblr_link_url = "{$this->ogdata['url']}";
    var tumblr_link_name = "{$this->ogdata['title']}";
    var tumblr_link_description = "{$this->ogdata['description']}";
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
EOT;
    }

    public function _get_hatenabookmark() {
        return <<<EOT
<a href="http://b.hatena.ne.jp/entry/{$this->ogdata['url']}" class="hatena-bookmark-button" data-hatena-bookmark-title="{$this->ogdata['title']}" data-hatena-bookmark-layout="{$this->config['og_hatena_size']}" title="このエントリーをはてなブックマークに追加"><img src="http://b.st-hatena.com/images/entry-button/button-only.gif" alt="このエントリーをはてなブックマークに追加" width="20" height="20" style="border: none;" /></a><script type="text/javascript" src="http://b.st-hatena.com/js/bookmark_button.js" charset="utf-8" async="async"></script>
EOT;
    }    

    public function _get_evernote() {
        return <<<EOT
<script type="text/javascript" src="http://static.evernote.com/noteit.js"></script>
<a href="#" onclick="Evernote.doClip({contentId:'{$this->config['og_evernote_id']}',providerName: '{$this->ogdata['title']}',suggestNotebook: '{$this->config['og_evernote_book']}',code: '{$this->config['og_evernote_code']}'}); return false;"><img src="http://static.evernote.com/{$this->config['og_evernote_size']}.png" alt="Clip to Evernote" /></a>
EOT;
    }

    public function _get_mixi() {
        return <<<EOT
<a href="http://mixi.jp/share.pl" class="mixi-check-button" data-key="{$this->config['og_mixi_key']}" data-url="{$this->ogdata['url']}" data-button="button-3">Check</a><script type="text/javascript" src="http://static.mixi.jp/js/share.js"></script>
EOT;
    }

    public function _get_gree() {
        return <<<EOT
<iframe src="http://share.gree.jp/share?url={$this->ogdata['url']}&type=0&height={$this->config['og_gree_size']}" scrolling="no" frameborder="0" marginwidth="0" marginheight="0" style="border:none; overflow:hidden; width:100px; height: {$this->config['og_gree_size']}px;" allowTransparency="true"></iframe>
EOT;
    }
}
?>
