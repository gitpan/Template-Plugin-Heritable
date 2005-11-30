#!/usr/bin/perl -w

use strict;
use Test::More tests => 1;
use Template;
use Template::Plugin;

our $start_t;
eval 'use Time::HiRes';
unless ( $@ ) {
    Time::HiRes->import(qw(gettimeofday tv_interval));
    $start_t = [gettimeofday()];
}
use_ok("Template::Plugin::Heritable");
diag("load time: ".sprintf("%.1fms",tv_interval($start_t)*1000))
    unless !$start_t;

