# $Id: Makefile.PL,v 1.1.1.1 2003-01-19 20:33:34 dstuart Exp $
###############################################################################
#
# File:    Makefile.PL
#
# Author:  Damien S. Stuart
#
# Purpose: Makefile.PL for the Authen::Krb5::Simple module.
#
###############################################################################
#
use ExtUtils::MakeMaker;

# Get krb5 info
#
my ($krb5_inc, $krb5_lib) = get_krb5_info();

# Write out the Makefile
#
WriteMakefile(
    'NAME'          => 'Authen::Krb5::Simple',
    'VERSION_FROM'  => 'lib/Authen/Krb5/Simple.pm',
    'PREREQ_PM'     => {},
    ($] >= 5.005
        ? (
            ABSTRACT   => 'Perl module that performs Kerberos 5 authentication',
            AUTHOR     => 'Damien S. Stuart <damien.stuart@usi.net>')
        : ()
    ),
    'LIBS'      => ["-L$krb5_lib -lkrb5 -lk5crypto -lcom_err"],
    'DEFINE'    => '',
    'INC'       => "-I$krb5_inc",
);

###############################################################################

sub get_krb5_info {
    # TODO: smarter code to figure out reasonable defaults for krb libs.
    # Figure out where the kerberos libs and include files are by staring with
    # a list of candidate directories.  Iterate through them hoping to find a
    # match.  Display the match as a default for the prompts.
    #
    my @krb_dirs = qw(
        /usr
        /usr/kerberos
        /usr/kerberos5
        /usr/krb
        /usr/krb5
        /opt/kerberos
        /opt/kerberos5
        /opt/krb
        /opt/krb5
        /usr/local
        /usr/local/kerberos
        /usr/local/kerberos5
        /usr/local/krb
        /usr/local/krb5
    );
    
    my $lflag = 0;
    my $iflag = 0;
    my $def_kinc = '';
    my $def_klib = '';

    foreach my $kdir (@krb_dirs) {
        my $klib = "$kdir/lib";
        my $kinc = "$kdir/include";
    
        if(glob "$klib/libkrb5.*") {
            $lflag = 1;
            $def_klib = $klib;
        }
    
        if(-f "$kinc/krb5.h") {
            $iflag = 1;
            $def_kinc = $kinc;
        }
    
        last if($lflag and $iflag);
    }
    
    # Prompt for the location of key Kerberos files.
    #
    print "\nPlease enter information about your Kerberos5 installation.\n";
    print " - (Press <Enter> to keep the default value):\n\n";
    
    my $krb_inc = get_resp('Enter Kerboros5 include directory', $def_kinc);
    my $krb_lib = get_resp('Enter Kerberos5 lib directory', $def_klib);

    return($krb_inc, $krb_lib);
}
 
sub get_resp {
    my $prompt  = shift || 'Answer?';
    my $default = shift || '';
    my $resp;

    $prompt .= " [ $default ]" if($default);

    print "\n$prompt: ";
    chomp($resp = <STDIN>);

    return($resp || $default);
}

###EOF###