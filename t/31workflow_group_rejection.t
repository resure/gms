#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

my $schema = need_database 'basic_db';
my $user = $schema->resultset('Account')->search({ accountname => 'test01' })->single;
my $admin = $schema->resultset('Account')->search({ accountname => 'admin01' })->single;

my $group = $schema->resultset('Group')->create({
        account => $user,
        group_type => 'informal',
        group_name => 'Test Group',
        url => 'http://www.example.com',
        address => undef,
    });

isa_ok $group, "GMS::Schema::Result::Group";

$group->auto_verify ($user, { 'freetext' => 'freetext' });

ok $group->verify($admin);

ok $group->reject($admin);
ok $group->status->is_deleted;

is $schema->resultset('Group')->search_active_groups->count, 0,
        "Rejected group is not active";

# Can't approve something already rejected
throws_ok { $group->approve($admin) }
          qr/Can't approve a group that isn't verified or pending verification/,
          "Can't approve rejected group";

done_testing;
