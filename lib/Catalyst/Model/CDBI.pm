package Catalyst::Model::CDBI;

use strict;
use base qw/Catalyst::Base Class::DBI/;
use NEXT;
use Class::DBI::Loader;

our $VERSION = '0.03';

__PACKAGE__->mk_accessors('loader');

=head1 NAME

Catalyst::Model::CDBI - CDBI Model Class

=head1 SYNOPSIS

    # use the helper
    create model CDBI CDBI dsn user password

    # lib/MyApp/Model/CDBI.pm
    package MyApp::Model::CDBI;

    use base 'Catalyst::Model::CDBI';

    __PACKAGE__->config(
        dsn           => 'dbi:Pg:dbname=myapp',
        password      => '',
        user          => 'postgres',
        options       => { AutoCommit => 1 },
        relationships => 1
    );

    1;

    # As object method
    $c->comp('MyApp::Model::CDBI::Table')->search(...);

    # As class method
    MyApp::Model::CDBI::Table->search(...);

=head1 DESCRIPTION

This is the C<Class::DBI>, C<Class::DBI::Loader> model class.

=cut

sub new {
    my ( $self, $c ) = @_;
    $self = $self->NEXT::new($c);
    $self->{namespace}               ||= ref $self;
    $self->{additional_base_classes} ||= ();
    push @{ $self->{additional_base_classes} }, ref $self;
    eval { $self->loader( Class::DBI::Loader->new(%$self) ) };
    if ($@) { $c->log->debug(qq/Couldn't load tables "$@"/) if $c->debug }
    else {
        $c->log->debug(
            'Loaded tables "' . join( ' ', $self->loader->tables ) . '"' )
          if $c->debug;
    }
    for my $class ( $self->loader->classes ) {
        $class->autoupdate(1);
        $c->components->{$class} ||= bless {%$self}, $class;
        no strict 'refs';
        *{"$class\::new"} = sub { bless {%$self}, $class };
    }
    return $self;
}

=head1 SEE ALSO

L<Catalyst>, L<Class::DBI>

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
