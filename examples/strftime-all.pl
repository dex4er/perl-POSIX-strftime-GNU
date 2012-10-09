#!/usr/bin/perl

use strict;
use warnings;

use POSIX ();

$ENV{TZ} = 'GMT';
POSIX::setlocale(&POSIX::LC_TIME, 'C');

my @format = qw( a A b B c C d D e Ec EC Ex EX EY Ey F G g h H I j k l m M n Od Oe OH OI Om OM OS Ou OU OV Ow Oy p P r R s S t T u U V w W x X y Y z Z );

my @t = localtime POSIX::mktime(54, 3, 21, 6, 6, 108);

foreach my $f (@format) {
    printf "%-2s => '%s',\n", $f, POSIX::strftime("%$f", @t);
};
