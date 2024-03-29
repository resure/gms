use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;
my $schema = GMS::Schema->do_connect;

my $change_rs = $schema->resultset('CloakNamespaceChange');

my $change11 = $change_rs->find({ 'id' => 11 });
my $change12 = $change_rs->find({ 'id' => 12 });

my $ns1 = $change11->namespace;
my $ns2 = $change12->namespace;

ok $ns1->status->is_deleted, 'namespace is deleted';
ok $ns2->status->is_active, 'namespace is active';

is $ns1->group->id, 4, 'namespace 1 group is 4';

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin01',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin01", "Check we can log in");

$ua->get_ok("http://localhost/admin/approve_change", "Change approval page works");

$ua->submit_form(
    fields => {
        change_item => 5
    }
);

$ua->submit_form(
    fields => {
        action_11 => 'approve',
        action_12 => 'reject'
    }
);

$ns1->discard_changes;
$ns2->discard_changes;

ok $ns1->status->is_active, 'namespace is now active';
is $ns1->group->id, 1, 'namespace 1 group is 1';
ok $ns1->last_change->change_type->is_approve, 'last change is approved';

ok $ns2->status->is_active, 'namespace status has not changed';
ok $ns2->last_change->change_type->is_reject, 'last change is rejected';

is $ns1->last_change->affected_change->id, 11, 'affected change is correct';
is $ns2->last_change->affected_change->id, 12, 'affected change is correct';

done_testing;
