package Novel::Robot::Packer::txt;
use strict;
use warnings;
use utf8;

use base 'Novel::Robot::Packer';
use HTML::FormatText;
use HTML::TreeBuilder;
use Template;

sub suffix {
    'txt';
}

sub main {
    my ($self, $bk, %opt) = @_;

    $self->{formatter} = HTML::FormatText->new() ;
    $self->format_content_to_txt($_) for @{$bk->{chapter_info}};

    $self->process_template($bk, %opt);
    return $opt{output};
}

sub format_content_to_txt {
    my ($self, $r) = @_;
    my $tree = HTML::TreeBuilder->new_from_content($r->{content});
    $r->{content} = $self->{formatter}->format($tree);
}

sub process_template {
    my ($self, $bk, %opt) = @_;
    my $txt = qq{
    [% writer %]《 [% book %] 》

    [% FOREACH r IN chapter_info %][% r.id %].  [% r.title %]
    [% END %]

    [% FOREACH r IN chapter_info %]
    [% r.id %].  [% r.title %]
    [% r.content %]
    [% END %]
    };
    my $tt=Template->new();
    $tt->process(\$txt, $bk, $opt{output}, { binmode => ':utf8' })  || die $tt->error(), "\n";
}

1;
