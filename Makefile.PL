use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    NAME             => 'acronym',
    AUTHOR           => q{Bernhard Graf <graf@cpan.org>},
    VERSION_FROM     => 'lib/acronym.pm',
    ABSTRACT_FROM    => 'lib/acronym.pm',
    LICENSE          => 'artistic_2',
    META_MERGE       => {
        'meta-spec'    => {version => 2},
        dynamic_config => 0,
        prereqs   => {
            runtime => {requires => {perl => '5.008'}}
        },
        resources => {
            bugtracker => {
                web => 'https://github.com/augensalat/perl-acronym/issues'
            },
            license    => [
                'http://www.opensource.org/licenses/artistic-license-2.0',
            ],
            repository => {
                type => 'git',
                url  => 'https://github.com/augensalat/perl-acronym.git',
                web  => 'https://github.com/augensalat/perl-acronym',
            },
        },
    },
    MIN_PERL_VERSION => '5.008',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '6.64',
    },
    TEST_REQUIRES => {
        'Test::Fatal' => '0',
        'Test::More'  => '0.90',
    },
    PREREQ_PM => {
        'Carp'      => '0',
        'Sub::Util' => '1.40',
    },
    dist  => {COMPRESS => 'gzip -9f', SUFFIX => 'gz'},
    clean => {FILES => 'acronym-*'},
);

# Compatibility with old versions of ExtUtils::MakeMaker
unless (eval { ExtUtils::MakeMaker->VERSION('6.64'); 1 }) {
    my $test_requires = delete $WriteMakefileArgs{TEST_REQUIRES} || {};
    @{$WriteMakefileArgs{PREREQ_PM}}{keys %$test_requires} = values %$test_requires;
}

unless (eval { ExtUtils::MakeMaker->VERSION('6.55_03'); 1 }) {
    my $build_requires = delete $WriteMakefileArgs{BUILD_REQUIRES} || {};
    @{$WriteMakefileArgs{PREREQ_PM}}{keys %$build_requires} = values %$build_requires;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
    unless eval { ExtUtils::MakeMaker->VERSION('6.52'); 1 };
delete $WriteMakefileArgs{MIN_PERL_VERSION}
    unless eval { ExtUtils::MakeMaker->VERSION('6.48'); 1 };
delete $WriteMakefileArgs{LICENSE}
    unless eval { ExtUtils::MakeMaker->VERSION('6.31'); 1 };

WriteMakefile(%WriteMakefileArgs);
