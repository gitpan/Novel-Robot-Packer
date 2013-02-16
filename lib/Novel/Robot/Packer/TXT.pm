package Novel::Robot::Packer::TXT;
use strict;
use warnings;
use utf8;
use Moo;
extends 'Novel::Robot::Packer::Base';
use HTML::TreeBuilder;
use HTML::FormatText;

sub BUILD {
    my ( $self ) = @_;

    my @args = map { $_ => $self->{$_} } %$self;
    my $formatter = HTML::FormatText->new(@args);
    $self->{formatter} = $formatter;
};

sub format_index {
    my ($self, $index) = @_;
    my $r = $index->{chapter_urls};
    my $title = "$index->{writer}  《$index->{book}》\n";
    my @chap_list = map { "chap $_ ".($r->[$_] || '') } (1 .. $index->{chapter_num});
    my $chap = join("\n", @chap_list);
    return "$title\n\n$chap\n\n";
}

sub format_chapter {
    my ( $self, $chap) = @_;
    my $tree = HTML::TreeBuilder->new_from_content("chap $chap->{id}<br>$chap->{content}");
    return $self->{formatter}->format($tree);
} ## end sub generate_chapter_url

1;
