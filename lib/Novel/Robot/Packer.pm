# ABSTRACT: 小说打包引擎
use strict;
use warnings;
package  Novel::Robot::Packer;
use Moo;
use Novel::Robot::Packer::TXT;
use Novel::Robot::Packer::HTML;

sub set_packer {
      my ( $self, $site , @opt) = @_;
      my $s = @opt?'@opt':'';
      $self->{packer} = eval qq[new Novel::Robot::Packer::$site($s)];
}

sub format_index {
    my ($self, @args) = @_;
    $self->{packer}->format_index(@args);
}

sub format_chapter {
    my ($self, @args) = @_;
    $self->{packer}->format_chapter(@args);
}

no Moo;
1;
