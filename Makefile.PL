use ExtUtils::MakeMaker;

WriteMakefile(
    NAME      => 'Catalyst::Model::CDBI',
    AUTHOR    => 'Sebastian Riedel (sri@oook.de)',
    PREREQ_PM => {
        Catalyst           => '2.99',
        Class::DBI         => 0,
        Class::DBI::Loader => 0
    },
    VERSION_FROM => 'CDBI.pm'
);
