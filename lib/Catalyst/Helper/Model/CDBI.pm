package Catalyst::Helper::Model::CDBI;

use strict;
use Class::DBI::Loader;

=head1 NAME

Catalyst::Helper::Model::CDBI - Helper for CDBI Models

=head1 SYNOPSIS

    bin/create model CDBI CDBI dsn user password

=head1 DESCRIPTION

Helper for CDBI Model.

=head2 METHODS

=head3 mk_compclass

=cut

sub mk_compclass {
    my ( $self, $helper, $dsn, $user, $pass ) = @_;
    $dsn  ||= '';
    $user ||= '';
    $pass ||= '';
    my $rel = 0;
    $rel = 1 if $dsn =~ /sqlite|pg|mysql/i;
    my $file    = $helper->{file};
    my $class   = $helper->{class};
    my $options = '';
    $options = 'AutoCommit => 1 ' if $dsn =~ /pg/i;
    $helper->{classes} = [];
    push( @{ $helper->{classes} }, $class )
      if $helper->mk_file( $file, <<"EOF");
package $class;

use strict;
use base 'Catalyst::Model::CDBI';

__PACKAGE__->config(
    dsn           => '$dsn',
    user          => '$user',
    password      => '$pass',
    options       => { $options},
    relationships => $rel
);

=head1 NAME

$class - CDBI Model Component

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice component.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
EOF
    return 1 unless $dsn;
    my $loader = Class::DBI::Loader->new(
        dsn       => $dsn,
        user      => $user,
        password  => $pass,
        namespace => $class
    );

    my $path = $file;
    $path =~ s/\.pm$//;
    $helper->mk_dir($path);

    for my $c ( $loader->classes ) {
        $c =~ /\W*(\w+)$/;
        my $f = $1;
        my $p = "$path/$f.pm";
        push( @{ $helper->{classes} }, $c ) if $helper->mk_file( $p, <<"EOF");
package $c;

use strict;

=head1 NAME

$c - CDBI Model Component Table Class

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice component.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
EOF
    }
    return 1;
}

=head3 mk_compclass

=cut

sub mk_comptest {
    my ( $self, $helper ) = @_;
    my $class = $helper->{class};
    my $app   = $helper->{app};
    my $test  = $helper->{test};
    my $name  = $helper->{name};
    my $type  = $helper->{type};

    for my $c ( @{ $helper->{classes} } ) {
        $c =~ /\:\:(\w+)$/;
        my $table  = $1;
        my $prefix = "$type\::$name\::$table";
        $prefix =~ s/::/_/g;
        $prefix = lc $prefix;
        my $test = $helper->next_test($prefix);
        $helper->mk_file( $test, <<"EOF");
use Test::More tests => 2;
use_ok( Catalyst::Test, '$app' );
use_ok('$c');
EOF
    }
}

=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Test>, L<Catalyst::Request>,
L<Catalyst::Response>, L<Catalyst::Helper>

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
