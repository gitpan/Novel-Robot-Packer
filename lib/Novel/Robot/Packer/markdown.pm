package Novel::Robot::Packer::markdown;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Packer';
use HTML::FormatText;
use HTML::TreeBuilder;
use Template;

sub suffix {
    'md';
}

sub main {
    my ($self, $bk, %opt) = @_;

    $self->{formatter} = HTML::FormatText->new() ;
    $self->tidy_content($_) for @{$bk->{chapter_info}};

    $self->process_template($bk, %opt);
    return $opt{output};
}

sub tidy_content {
    my ($self, $r) = @_;
    my $tree = HTML::TreeBuilder->new_from_content($r->{content});
    $r->{content} = $self->{formatter}->format($tree);

    for($r->{title}, $r->{content}){
        s/\n{3,}/\n\n/gs;
        s/\n[\s#]+/\n\n/gs;
        tr/=*[]()>_<|&/＝＊［］（）＞＿＜｜＆/;
    }

    $r->{content};
}

sub process_template {
    my ($self, $bk, %opt) = @_;
    my $txt = 
qq{# [[% writer %]]([% writer_url %])《 [[% book %]]([% index_url %]) 》

[% FOREACH r IN chapter_info %]- \[[% r.title %]\](#chap[% r.id %])
[% END %]

[% FOREACH r IN chapter_info %]
<h1 id="chap[% r.id %]">  [% r.id %] [% r.title %]  </h1>\n\n
[% r.content %]
[% END %]
    };
    my $tt=Template->new();
    $tt->process(\$txt, $bk, $opt{output}, { binmode => ':utf8' })  || die $tt->error(), "\n";
}

1;
