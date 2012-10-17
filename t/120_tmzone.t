#!/usr/bin/perl

use strict;
use warnings;

use constant TMZONE => 'CET-1CEST';

BEGIN {
    # Windows can't change timezone inside Perl script
    if (($ENV{TZ}||'') ne TMZONE) {
        $ENV{TZ} = TMZONE;
        exec $^X, (map { "-I$_" } @INC), $0;
    };
}

use Carp ();
use File::Spec;
use Time::Local;

$SIG{__WARN__} = sub { local $Carp::CarpLevel = 1; Carp::confess("Warning: ", @_) };

use Test::More tests => 6;

BEGIN { use_ok 'POSIX::strftime::GNU'; }
BEGIN { use_ok 'POSIX', qw( strftime ); }

POSIX::setlocale(&POSIX::LC_TIME, 'C');

my @t1 = localtime timelocal(0, 0, 0, 1, 1, 112);
my @t2 = localtime timelocal(0, 0, 0, 1, 7, 112);

is strftime('%z', @t1), '+0100', "tmzone1";
is strftime('%Z', @t1), 'CET',   "tmname1";
is strftime('%z', @t2), '+0200', "tmzone2";
is strftime('%Z', @t2), 'CEST',  "tmname2";
