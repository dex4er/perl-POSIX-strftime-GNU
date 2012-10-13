#!/usr/bin/perl

use strict;
use warnings;

use Carp ();
use File::Spec;
use Time::Local;

$SIG{__WARN__} = sub { local $Carp::CarpLevel = 1; Carp::confess("Warning: ", @_) };

use Test::More $^O eq 'linux' ? (tests => 26) : (skip_all => 'This test can run only on Linux with tzdata');

BEGIN { use_ok 'POSIX::strftime::GNU'; }
BEGIN { use_ok 'POSIX', qw( strftime ); }

POSIX::setlocale(&POSIX::LC_TIME, 'C');

my %tmzone = (
    'Asia/Riyadh89'       => [qw( +0307 zzz    +0307 zzz    )],
    'Australia/Lord_Howe' => [qw( +1100 LHST   +1030 LHST   )],
    'GMT'                 => [qw( +0000 GMT    +0000 GMT    )],
    'Japan'               => [qw( +0900 JST    +0900 JST    )],
    'Poland'              => [qw( +0100 CET    +0200 CEST   )],
    'PST8PDT'             => [qw( -0800 PST    -0700 PDT    )],
);

my @t1 = localtime timelocal(0, 0, 0, 1, 1, 112);
my @t2 = localtime timelocal(0, 0, 0, 1, 7, 112);

foreach my $tm (sort keys %tmzone) {
    $ENV{TZ} = $tm;
    my ($tmzone1, $tmname1, $tmzone2, $tmname2) = @{ $tmzone{$tm} };
    is strftime('%z', @t1), $tmzone1, "tmzone1 for $tm";
    is strftime('%Z', @t1), $tmname1, "tmname1 for $tm";
    is strftime('%z', @t2), $tmzone2, "tmzone2 for $tm";
    is strftime('%Z', @t2), $tmname2, "tmname2 for $tm";
};
