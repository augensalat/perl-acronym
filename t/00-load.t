#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok 'acronym', foo => 'BAR' or print "Bail out!\n";
}

diag "Testing acronym $acronym::VERSION, Perl $], $^X";
