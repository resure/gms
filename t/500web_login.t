#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

need_database 'basic_db';

$SIG{__DIE__} = sub { Carp::confess @_ };

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'test01',
        password => 'tester01'
    }
);

$ua->content_contains("You are now logged in as test01", "Check we can log in");

done_testing;
