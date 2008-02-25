# $Id: 02-ops.t,v 1.1.1.1 2003-01-19 20:33:34 dstuart Exp $
###############################################################################
# Authen::Krb5::Simple Test Script
#
# File: 02-ops.t
#
# Purpose: Make sure we can create and use an Authen::Krb5::Simple object.
#
###############################################################################
#
use strict;

use Test;

use Authen::Krb5::Simple;

BEGIN { plan tests => 10 };

# Get test user params (if any)
#
my $tdata = get_test_data();

my $krb = Authen::Krb5::Simple->new();

# Valid object.
#
ok(ref($krb) =~ /Authen::Krb5::Simple/);

my $verbose = $ENV{verbose} || 0;

my $ret;

# Good pw
#
if(defined($tdata->{user}) and defined($tdata->{password})) {
    my $tuser = $tdata->{user};
    my $tpass = $tdata->{password};

    $tuser .= "\@$tdata->{realm}" if(defined($tdata->{realm}));

    $ret = $krb->authenticate($tuser, $tpass);

    my $errcode = $krb->errcode();
    my $errstr  = $krb->errstr();

    print STDERR "\nGPW RET: $ret (code=$errcode, str=$errstr)\n" if($verbose);

    ok($ret);

    # Valid error conditions
    ok($errcode == 0);
    ok($errstr eq '');

    # Now munge the pw and make sure we get the expected responses
    #
    $ret = $krb->authenticate($tuser, "x$tpass");

    $errcode = $krb->errcode();
    $errstr  = $krb->errstr();

    print STDERR "\nGPW2 RET: $ret (code=$errcode, str=$errstr)\n" if($verbose);

    ok(!$ret);

    ok($errcode != 0);
    ok($errstr ne '');

} else {
    skip(1,'Skipped good auth');
    skip(1,'Skipped good auth errcode');
    skip(1,'Skipped good auth errstr');
    skip(1,'Skipped bad auth');
    skip(1,'Skipped bad auth errcode');
    skip(1,'Skipped bad auth errstr');
}

# Bad user and pw
#
$ret = $krb->authenticate('_xxx', '_xxx');
print STDERR "\nBPW RET: $ret\n" if($verbose);
ok($ret == 0);

# Valid error conditions
ok($krb->errcode() != 0);
ok($krb->errstr());

sub get_test_data {
    my %tdata;

    unless(open(CONF, "<CONFIG")) {
        print STDERR "\nUnable to read CONFIG file: $!\nSkipping user auth tests\n";
        return undef;
    }

    while(<CONF>) {
        chomp;
        next if(/^\s*#|^\s*$/);

        $tdata{user} = $1 if(/^\s*TEST_USER\s+(.*)/);
        $tdata{password} = $1 if(/^\s*TEST_PASS\s+(.*)/);
        $tdata{realm} = $1 if(/^\s*TEST_REALM\s+(.*)/);
    }
    close(CONF);

    return(\%tdata);  
}

###EOF###
