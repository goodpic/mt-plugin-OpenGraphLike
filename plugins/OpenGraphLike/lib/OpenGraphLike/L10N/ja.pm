package OpenGraphLike::L10N::ja;

use strict;
use base 'OpenGraphLike::L10N';
use vars qw( %Lexicon );

our %Lexicon = (
    'Use Excerpt' => '本文でなく概要を利用',
    'Common Settings' => '共通設定',
    'Include count' => 'Plus数を表示',
    'Button Size' => 'ボタンのサイズ',
    '@ mention' => '@ メンション',
    'Show Faces' => '顔写真を表示',
    'Verb to Display' => 'ボタンの文言',
    'Width' => '幅',
    'Font' => 'フォント',
    'Contents ID' => 'クリップするhtmlのid',
    'Color Scheme' => '色合い',
    'Send Button' => 'Sendボタンを表示',
    "This plugin adds various social like button to your blog. The Like button lets a user share your content with friends on Facebook, Google+, Twitter, Tumblr, Evernote, etc. When the user clicks the Like button on your site, a story appears in the user's friends' News Feed with a link back to your website." => '様々なソーシャルサービスのLikeボタンをブログに追加します。Facebook, Google+, Twitter, Tumblr, Evernote, はてなブックマーク, Mixi, Gree に対応します。ブログに設置したLikeボタンをユーザーがクリックすると、各ソーシャルサービスのユーザーのタイムラインに通知されます。<br /> &lt;$MTOpenGraphMeta$&gt; タグをテンプレートのhtmlのhead内に記述し、各ボタンのMTタグを表示したい場所に記述します。Tumblrボタンを利用する場合は、html のフッターに&lt;$MTTumblrJS$&gt;を記述してください。',
    'Tall with count' => '縦長 (数を表示)',
    'Horizontal with count' => '横長 (数を表示)',
    'Horizontal without count' => '横長 (数なし)',
    '' => '',
    '' => '',
    '' => '',
    '' => '',
);

1;
