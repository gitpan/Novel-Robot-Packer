package Novel::Robot::Packer::HTML;
use strict;
use warnings;
use utf8;
use Moo;
extends 'Novel::Robot::Packer::Base';

sub format_index {
    my ( $self, $index ) = @_;
    my $index_url  = $index->{index_url};
    my $title      = "$index->{writer}  《$index->{book}》\n";
    my $toc        = $self->generate_toc($index);
    my $index_html = qq[<div id="title"><a href="$index_url"> $title </a></div>
    <div id="toc"><ol>
    $toc
    </ol></div>
    ];

    return $index_html;
} ## end sub format_index

sub generate_toc {
    my ( $self, $r ) = @_;
    my $toc = '';

    for my $i ( 1 .. $r->{chapter_num} ) {
        my $u = $r->{chapter_urls}[$i];
        next unless ($u);

        my $t = $r->{chapter_info}[$i]{title} || '';
        $toc .= qq`<li><a href="#toc$i">$t</a></li>\n`;
    } ## end for my $i ( 1 .. $r->{chapter_num...})

    return $toc;
} ## end sub generate_toc

sub format_chapter {
    my ( $self, $chap ) = @_;
    my $j = sprintf( "%03d# ", $chap->{chapter_id} );
    my $floor = <<__FLOOR__;
<div class="floor">
<div class="fltitle">$j<a name="toc$chap->{chapter_id}">$chap->{chapter}</a></div>
<div class="flcontent">$chap->{content}</div>
</div>
__FLOOR__
    return $floor;
} ## end sub format_chapter

1;
