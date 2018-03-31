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
#use lib qw(inc);
BEGIN {
    die "You must install the Devel::CheckLib module to build Authen::Krb5::Simple\n"
        unless(eval "require Devel::CheckLib");

}

use ExtUtils::MakeMaker;

my ($krb5_inc, $krb5_lib);

# Places we might find Kerberos5 libs.
#
my @krb_lib_dirs =  qw(
    /usr/lib64
    /usr/lib
    /usr/local/lib64
    /usr/local/lib
    /usr/lib64/krb5
    /usr/lib/krb5
    /usr/local/lib64/krb5
    /usr/local/lib/krb5
    /usr/lib64/krb
    /usr/lib/krb
    /usr/local/lib64/krb
    /usr/local/lib/krb
    /opt/local/lib
    /opt/local/lib64
    /opt/local/lib/krb5
    /opt/local/lib64/krb5
    /opt/local/lib/krb
    /opt/local/lib64/krb
    /opt/local/krb/lib
    /opt/local/krb5/lib
    /opt/local/krb/lib64
    /opt/local/krb5/lib64
    /opt/krb5/lib64
    /opt/krb5/lib
    /opt/krb/lib64
    /opt/krb/lib
    /usr/heimdal/lib64
    /usr/heimdal/lib
    /usr/local/heimdal/lib64
    /usr/local/heimdal/lib
    /opt/local/heimdal/lib64
    /opt/local/heimdal/lib
    /opt/heimdal/lib64
    /opt/heimdal/lib
);

# If the ENV vars are specified, use them.
#
if(exists($ENV{KRB5_INCLUDE})) {
    $krb5_inc = "-I$ENV{KRB5_INCLUDE}";
}
if(exists($ENV{KRB5_LIB})) {
    $krb5_lib = "-L$ENV{KRB5_LIB}";
    unshift(@krb_lib_dirs, $ENV{KRB5_LIB});
}

# See if the needed libs are available.  Take a shot at several "possible"
# locations for these libs.
#
Devel::CheckLib::check_lib_or_exit(
    lib     => [qw( krb5 )],
    libpath => \@kr_lib_dirs
) unless($ENV{skip_lib_check});

# Write out the Makefile
#
WriteMakefile(
    'NAME'          => 'Authen::Krb5::Simple',
    'VERSION_FROM'  => 'lib/Authen/Krb5/Simple.pm',
    'PREREQ_PM'     => {
        'Devel::CheckLib' => 0,
        'Test::More' => 0,
    },
    ($] >= 5.006
        ? (
            ABSTRACT   => 'Perl module that performs Kerberos 5 authentication',
            AUTHOR     => 'Damien S. Stuart <dstuart@dstuart.org>')
        : ()
    ),
    'BUILD_REQUIRES'   => {
        'Devel::CheckLib' => 0,
        'Test::More' => 0,
    },
    'LIBS'      => ["$krb5_lib -lkrb5"],
    'DEFINE'    => '',
    'INC'       => $krb5_inc,
);


###EOF###
