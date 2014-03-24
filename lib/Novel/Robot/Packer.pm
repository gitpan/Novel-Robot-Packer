# ABSTRACT: 小说打包引擎

=pod

=encoding utf8

=head1 支持输出类型

    txt  : txt形式的小说

    html : 网页形式的小说

    wordpress : 将小说发布到WordPress空间

=head1 FUNCTION

=head2 new 初始化解析模块

   my $packer = Novel::Robot::Packer->new(type => 'html');

=head2 打包文件
   
   my $ret = $self->main($book_ref, 
       with_toc => 1, 
   );

=cut

package  Novel::Robot::Packer;
use strict;
use warnings;
use Encode::Locale;
use Encode;

our $VERSION = 0.14;

sub new {
    my ( $self, %opt ) = @_;
    $opt{type} ||= 'html';
    my $module = "Novel::Robot::Packer::$opt{type}";
    eval "require $module;";
    bless {%opt}, $module;
}

sub format_book_output {
    my ( $self, $bk, $o ) = @_;
    if ( ! $o->{output} ) {
        my $html = '';
        $o->{output} =
          exists $o->{output_scalar}
          ? \$html
          : $self->format_default_filename($bk, $o);
    }
    return $o->{output};
}

sub format_default_filename {
    my ( $self, $r, $o) = @_;
    my $f =  "$r->{writer}-$r->{book}." . $self->suffix();
    $f =~ s{[\[\]/><\\`;'\$^*\(\)\%#@!"&:\?|\s^,~]}{}g;
    return encode( locale => $f );
}

sub suffix {
    return '';
}

1;
