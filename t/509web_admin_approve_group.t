use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;
use Test::More;

need_database 'pending_changes';

use ok 'Test::WWW::Mechanize::Catalyst' => 'GMS::Web';

my $ua = Test::WWW::Mechanize::Catalyst->new;

$ua->get_ok("http://localhost/", "Check root page");

$ua->get_ok("http://localhost/login", "Check login page works");
$ua->content_contains("Login to GMS", "Check login page works");

$ua->submit_form(
    fields => {
        username => 'admin01',
        password => 'admin001'
    }
);

$ua->content_contains("You are now logged in as admin01", "Check we can log in");

$ua->get_ok("http://localhost/admin/approve", "Group approval page works");

$ua->submit_form(
    fields => {
        action_2 => 'verify',
        action_3 => 'approve',
    }
);

my $schema = GMS::Schema->do_connect;

my $rs = $schema->resultset('Group');

my $group2 = $rs->find({ id => 2 });
my $group3 = $rs->find({ id => 3 });

ok $group2->status->is_verified, 'verified group is verified';
ok $group3->status->is_active, 'approved group is active';

$ua->get_ok("http://localhost/admin/approve", "Group approval page works");

$ua->submit_form(
    fields => {
        action_2 => 'reject',
    }
);

$group2->discard_changes;
ok $group2->status->is_deleted, 'group is now deleted';

done_testing;
