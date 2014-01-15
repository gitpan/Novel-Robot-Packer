# ABSTRACT: 打包小说基础引擎 =pod

=encoding utf8

=head1 FUNCTION

=head2 open_packer 打开打包文件
   
   my ($write_sub, $ret) = $self->open_packer($index_ref, $opt);

   # $opt->{filename}
   # $opt->{write_scalar}

=head2 write_packer 写入内容
   
   $self->write_packer($write_sub, $c);

=head2 format_before_index

  $self->format_before_index($index_ref);

=head2 format_index

  $self->format_index($index_ref);

=head2 format_before_chapter

  $self->format_before_chapter($index_ref);

=head2 format_chapter

  $self->format_chapter($chapter_ref, $chapter_id);

=head2 format_after_chapter

  $self->format_after_chapter($index_ref);

=cut
use strict;
use warnings;
package  Novel::Robot::Packer::Base;
use Moo;
use Encode::Locale;
use Encode;

has 'suffix'    => ( is => 'rw');


sub open_packer {
    my ($self, $index_ref, $o) = @_;
    return $self->get_sub_write_scalar($index_ref, $o) if(exists $o->{write_scalar});
    return $self->get_sub_write_file($index_ref, $o);
}

sub get_sub_write_scalar {
    my ($self, $index_ref, $o) = @_;

    $o->{write_scalar} = '';
    open my $fh, '>:utf8', \$o->{write_scalar};

    my $write_sub = sub {
        my ($c) = @_;
        print $fh $c,"\n\n";
    };

    my $end_sub = sub {
        return (
            \$o->{write_scalar}, 
            writer => $index_ref->{writer}, 
            book => $index_ref->{book}
        );
    };

    return ($write_sub, $end_sub);
}

sub get_sub_write_file {
    my ($self, $index_ref, $o) = @_;

    my $fname = $self->format_filename($index_ref, $o);

    open my $fh, '>:utf8', $fname;
    my $write_sub = sub {
        my ($c) = @_;
        print $fh $c,"\n\n";
    };

    return $write_sub;
}

sub format_default_filename {
    my ($self, $r) = @_;
    return "$r->{writer}-$r->{book}.$self->{suffix}";
}

sub format_filename {
    my ($self, $r, $o) = @_;
    my $filename = $o->{filename} || $self->format_default_filename($r);
    $filename=~s{[\[\]/><\\`;'\$^*\(\)\%#@!"&:\?|\s^,~]}{}g;
    
    my $fname = encode( locale  => $filename);
    return $fname;
}

sub write_packer {
    my ($self, $write_sub, $content)  = @_;
    return unless($content);
    $write_sub->($content);
}

sub format_before_index { }
sub format_index { }
sub format_before_chapter { }
sub format_chapter { }
sub format_after_chapter { }

sub pack_book {
    my ($self, $index_ref, $o) =@_;

    my ( $w_sub, $end_sub ) = $self->open_packer( $index_ref, $o );

    $self->write_packer( $w_sub, $self->format_before_index($index_ref) );
    $self->write_packer( $w_sub, $self->format_index($index_ref) );
    $self->write_packer( $w_sub, $self->format_before_chapter($index_ref) );
    for my $chap_r (@{$index_ref->{chapter_info}}){
        $self->write_packer( $w_sub, $self->format_chapter($chap_r) );
    }
    $self->write_packer( $w_sub, $self->format_after_chapter($index_ref) );

    return $end_sub->() if($end_sub and ref($end_sub) eq 'CODE');
    return $end_sub;
}

no Moo;
1;