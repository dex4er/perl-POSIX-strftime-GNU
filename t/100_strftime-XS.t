#!/usr/bin/perl

use strict;
use warnings;

BEGIN {
    # Windows can't change timezone inside Perl script
    if (($ENV{TZ}||'') ne 'GMT') {
        $ENV{TZ} = 'GMT';
        exec $^X, (map { "-I$_" } @INC), $0;
    };
}

use Carp ();
use File::Spec;
use POSIX ();
use Time::Local;

$SIG{__WARN__} = sub { local $Carp::CarpLevel = 1; Carp::confess("Warning: ", @_) };

use Test::More eval { require POSIX::strftime::GNU::XS } ? (tests => 60) : (skip_all => $@);

POSIX::setlocale(&POSIX::LC_TIME, 'C');

*strftime = \&POSIX::strftime::GNU::XS::strftime;

my %format = (
    a  => 'Sun',
    A  => 'Sunday',
    b  => 'Jul',
    B  => 'July',
    C  => '20',
    d  => '06',
    D  => '07/06/08',
    e  => ' 6',
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
    ':z' => '+00:00',
    '::z' => '+00:00:00',
    ':::z' => '+00',
    Z  => 'GMT',
    '%' => '%',
);

my @t = localtime timelocal(54, 3, 21, 6, 6, 108);

foreach my $f (sort keys %format) {
    is strftime("%$f", @t), $format{$f}, "%$f";
}
