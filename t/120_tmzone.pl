#!/usr/bin/perl

use strict;
use warnings;

use POSIX::strftime::GNU;
use POSIX qw(strftime);
use Time::Local;

POSIX::setlocale(&POSIX::LC_TIME, 'C');

my $fmt = shift @ARGV || '%z';
my @t = @ARGV ? localtime timelocal(@ARGV) : localtime;

print strftime $fmt, @t;
