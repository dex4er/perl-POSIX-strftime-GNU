#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::PPPort;

use File::Find;

find(sub { $_ eq 'ppport.h' and ppport_ok }, '.');
