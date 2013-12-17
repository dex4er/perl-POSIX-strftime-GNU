#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::PPPort;

use File::Find;

my $found;

find(sub { if ($_ eq 'ppport.h') { $found = 1; ppport_ok; } }, '.');

ppport_ok if not $found;
