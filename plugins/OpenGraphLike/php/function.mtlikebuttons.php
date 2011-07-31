<?php
include_once "class.og_like.php";

function smarty_function_mtlikebuttons($args, &$ctx) {
    $oglike = new OGLike($args, $ctx);
    return $oglike->_get_facebooklike()
        . $oglike->_get_googleplus()
        . $oglike->_get_tweet()
        . $oglike->_get_hatenabookmark()                
        . $oglike->_get_tumblr()
        . $oglike->_get_evernote()
        . $oglike->_get_mixi()
        . $oglike->_get_gree()
        ;
}
?>
