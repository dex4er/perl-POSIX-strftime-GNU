#!/usr/bin/perl

use strict;
use warnings;

use Carp ();
use File::Spec;

$SIG{__WARN__} = sub { local $Carp::CarpLevel = 1; Carp::confess("Warning: ", @_) };

use Test::More tests => 59;

BEGIN { use_ok 'POSIX::strftime::GNU::PP'; }

*strftime = *POSIX::strftime::GNU::PP::strftime;

$ENV{TZ} = 'GMT';
POSIX::setlocale(&POSIX::LC_TIME, 'C');

my %format = (
    a  => 'Sun',
    A  => 'Sunday',
    b  => 'Jul',
    B  => 'July',
    c  => 'Sun Jul  6 21:03:54 2008',
    C  => '20',
    d  => '06',
    D  => '07/06/08',
    e  => ' 6',
    Ec => 'Sun Jul  6 21:03:54 2008',
    EC => '20',
    Ex => '07/06/08',
    EX => '21:03:54',
    EY => '2008',
    Ey => '08',
    F  => '2008-07-06',
    G  => '2008',
    g  => '08',
    h  => 'Jul',
    H  => '21',
    I  => '09',
    j  => '188',
    k  => '21',
    l  => ' 9',
    m  => '07',
    M  => '03',
    n  => "\n",
    Od => '06',
    Oe => ' 6',
    OH => '21',
    OI => '09',
    Om => '07',
    OM => '03',
    OS => '54',
    Ou => '7',
    OU => '27',
    OV => '27',
    Ow => '0',
    Oy => '08',
    p  => 'PM',
    P  => 'pm',
    r  => '09:03:54 PM',
    R  => '21:03',
    s  => '1215378234',
    S  => '54',
    t  => "\t",
    T  => '21:03:54',
    u  => '7',
    U  => '27',
    V  => '27',
    w  => '0',
    W  => '26',
    x  => '07/06/08',
    X  => '21:03:54',
    y  => '08',
    Y  => '2008',
    z  => '+0000',
    Z  => 'GMT',
);

my @t = localtime POSIX::mktime(54, 3, 21, 6, 6, 108);

foreach my $f (sort keys %format) {
    is strftime("%$f", @t), $format{$f}, "%$f";
}
