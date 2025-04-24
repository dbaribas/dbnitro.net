#!/usr/bin/env perl
# vi: set expandtab ts=4 sw=4 sts=4 si:
# Changelog
#
# 2014-11-25 Developer (1.1)
#   * first stable release
#
# 2014-12-16 Developer (1.2)
#   * colored status output
#
# 2014-12-18 Developer (3)
#   * New release schema
#   * -p parameter for database modification, will create/update spfile pointer
#   * create audit file dest if not existing
#   * better colored output
#
# 2014-12-18 Developer (4)
#   * some refactoring
#   * more logging
#   * diskgroup dependencies
#   * add node to status output
#
# 2014-12-22 Developer (5)
#   * -start/-stop without dbname to start/stop all databases managed by rcctl
#
# 2015-01-29 Developer (6)
#   * added -b install parameter ro specify oracle base
#   * several bugfixes
#
# 2015-03-10 Developer (10)
#   * complete rewrite for better argument handling
#   * new features include:
#       - create spfile pointer/audit dest when needed on startup
#       - better error reporting/logging
#       - split of database specific and generic application type
#       - diskgroup, spfile & auditdest are resource attributes
#
# 2015-03-25 Developer (11)
#   * blackout mode
#   * add resource check before printing status
#
# 2015-03-27 Developer (12)
#   * make blackout an object with start/stop commands
#   * several bugfixes
#   * don't error out of sqlplus when stopping database
#
# 2015-05-19 Developer
#   * Fix multiline status output
#
# 2015-05-20 Developer (13)
#   * No error when checking db with monitoring user, make status partial
#
# 2015-05-21 Developer (14)
#   * Added "sysresv -f" when cleaning db
#   * Better multiline error output when checking db
#
# 2015-06-08 Developer (14 SAB merge)
#   * emclitarget option
#   * vipname option
#   * emcli bugfix
#
# 2015-06-16 Developer (15)
#   * Ask for password twice and check for similarity
#   * Add basic password encoding, maybe replace later
#
# 2015-06-19 Developer (16)
#   * Fix password when installing emcli
#   * Fix emcli relocate
#
# 2015-06-22 Developer (17)
#   * Add parsing for invalid arguments
#   * Inform about valid objects when not specifying a valid one
#
# "-----------------------------------------------------------------------------------------------------"
# Required: perl-URI
use strict;
use warnings;
use File::Spec;
use File::Copy;
use POSIX "strftime";
use POSIX ":sys_wait_h";
use Term::ANSIColor;
use Term::Cap;
use constant PROGNAME           => 'rcctl';
use constant RELEASE            => 17;
use constant INSTALLPATH        => '/etc/ribas';
use constant OLRLOC             => '/etc/oracle/olr.loc';
use constant ORAGCHOMELIST      => '/etc/oragchomelist';
use constant CRSCTL             => 'crsctl';
use constant SQLPLUS            => 'sqlplus';
use constant OLSNODES           => 'olsnodes';
use constant ORABASE            => 'orabase';
use constant LOG_L_ERROR        => 0;
use constant LOG_L_WARNING      => 1;
use constant LOG_L_INFO         => 2;
use constant LOG_L_DEBUG        => 3;
use constant CRS_RCCTL_BASETYPE => 'orcl.base.type';
use constant CRS_RCCTL_DB_TYPE  => 'orcl.database.type';
use constant CRS_BASETYPE       => 'cluster_resource';
# "-----------------------------------------------------------------------------------------------------"
my @crs_basetype_attrs = (
    "ATTRIBUTE=ACTIVE_PLACEMENT,TYPE=int,FLAGS=REQUIRED,DEFAULT_VALUE=0",
    "ATTRIBUTE=SCRIPT_TIMEOUT,TYPE=int,FLAGS=REQUIRED,DEFAULT_VALUE=120"
);
my @crs_dbtype_attrs = (
    "ATTRIBUTE=USR_DB_HOME,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=",
    "ATTRIBUTE=USR_DB_SID,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=",
    "ATTRIBUTE=USR_DB_STOPMODE,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=immediate",
    "ATTRIBUTE=USR_DB_STARTMODE,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=open",
    "ATTRIBUTE=USR_DB_USER,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=dbsnmp",
    "ATTRIBUTE=USR_DB_PASS,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=dbsnmp",
    "ATTRIBUTE=USR_DB_SPFILE,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=",
    "ATTRIBUTE=USR_DB_AUDITDEST,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=",
    "ATTRIBUTE=USR_DB_DISKGROUPS,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=",
    "ATTRIBUTE=USR_DB_SHUTDOWN_TIMEOUT,TYPE=int,FLAGS=REQUIRED,DEFAULT_VALUE=60",
    "ATTRIBUTE=USR_DB_EMCLI_ENABLED,TYPE=int,FLAGS=REQUIRED,DEFAULT_VALUE=0",
    "ATTRIBUTE=USR_DB_EMCLI_TARGET,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=",
    "ATTRIBUTE=USR_DB_BLACKOUT,TYPE=int,FLAGS=REQUIRED,DEFAULT_VALUE=0",
    "ATTRIBUTE=USR_DB_VIPNAME,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=",
    "ATTRIBUTE=RESTART_ATTEMPTS,TYPE=int,FLAGS=REQUIRED,DEFAULT_VALUE=3"
);
my @crs_types = (
    {
        name     => CRS_RCCTL_BASETYPE,
        basetype => CRS_BASETYPE,
        attrs    => [ @crs_basetype_attrs ],
    },
    {
        name     => CRS_RCCTL_DB_TYPE,
        basetype => CRS_RCCTL_BASETYPE,
        attrs    => [ @crs_dbtype_attrs ],
    }
);
my @loglevel_d = (
    'ERROR',
    'WARNING',
    'INFO',
    'DEBUG',
);
my $logfile;
my $loglevel = LOG_L_WARNING;
my $loglevel_out = LOG_L_INFO;
# "-----------------------------------------------------------------------------------------------------"
# Global Sub-Pointers for argument handling
# "-----------------------------------------------------------------------------------------------------"
my %installptr       = ();
my %installedptr     = ();
my %cmd_add_ptr      = ();
my %cmd_stop_ptr     = ();
my %cmd_start_ptr    = ();
my %cmd_check_ptr    = ();
my %cmd_clean_ptr    = ();
my %cmd_config_ptr   = ();
my %cmd_modify_ptr   = ();
my %cmd_remove_ptr   = ();
my %cmd_status_ptr   = ();
my %cmd_relocate_ptr = ();
my %objaliases       = ( db => 'database', );
# "-----------------------------------------------------------------------------------------------------"
$installptr{'-i'}             = \&install;
$installptr{'-deploy'}        = \&deploy;
$installptr{'-icrs'}          = \&install_crs_types;
$installptr{'-emcli'}         = \&install_emcli;
$installptr{'-emclideploy'}   = \&deploy_emcli;
$installptr{'-h'}             = \&print_install_help;
$cmd_start_ptr{''}            = \&agent_start;
$cmd_stop_ptr{''}             = \&agent_stop;
$cmd_check_ptr{''}            = \&agent_check;
$cmd_clean_ptr{''}            = \&agent_clean;
$cmd_status_ptr{''}           = \&resource_status;
$cmd_stop_ptr{'blackout'}     = \&blackout_stop;
$cmd_start_ptr{'blackout'}    = \&blackout_start;
$cmd_add_ptr{'database'}      = \&db_add;
$cmd_stop_ptr{'database'}     = \&db_stop;
$cmd_start_ptr{'database'}    = \&db_start;
$cmd_config_ptr{'database'}   = \&db_config;
$cmd_modify_ptr{'database'}   = \&db_modify;
$cmd_remove_ptr{'database'}   = \&db_remove;
$cmd_relocate_ptr{'database'} = \&db_relocate;
$installedptr{'add'}          = \%cmd_add_ptr;
$installedptr{'stop'}         = \%cmd_stop_ptr;
$installedptr{'start'}        = \%cmd_start_ptr;
$installedptr{'check'}        = \%cmd_check_ptr;
$installedptr{'clean'}        = \%cmd_clean_ptr;
$installedptr{'modify'}       = \%cmd_modify_ptr;
$installedptr{'config'}       = \%cmd_config_ptr;
$installedptr{'remove'}       = \%cmd_remove_ptr;
$installedptr{'status'}       = \%cmd_status_ptr;
$installedptr{'relocate'}     = \%cmd_relocate_ptr;
# "-----------------------------------------------------------------------------------------------------"
# SQL-Scripts
# "-----------------------------------------------------------------------------------------------------"
my $SCRIPT_DB_STARTUP         = PROGNAME . ".startup.sql";
my $SCRIPT_DB_SHUTDOWN        = PROGNAME . ".shutdown.sql";
my $SCRIPT_DB_STATUS          = PROGNAME . ".status.sql";
my %sqlfiles = ();
use constant TRIMMED_SQL     => "
set trimout on;
set heading off;
set headsep off;
set feedback off;
set newpage none;
";
# "-----------------------------------------------------------------------------------------------------"
$sqlfiles{$SCRIPT_DB_STARTUP} =
"set define on;
set echo on;
whenever sqlerror exit failure;
connect / as sysdba;
startup &&1;
exit;";
# "-----------------------------------------------------------------------------------------------------"
$sqlfiles{$SCRIPT_DB_SHUTDOWN} =
"set define on;
set echo on;
connect / as sysdba;
shutdown &&1;
exit;";
# "-----------------------------------------------------------------------------------------------------"
$sqlfiles{$SCRIPT_DB_STATUS} =
TRIMMED_SQL .
"
set define on;
set echo off;
whenever sqlerror exit failure;
connect &&1/&&2 &&3;
set echo on;
select status from v\$instance;
exit;
";
# "-----------------------------------------------------------------------------------------------------"
# SECTION: GENERIC #
# "-----------------------------------------------------------------------------------------------------"
#
# sub: r_clrscr
#
sub r_clrscr {
    my $term;
    my $termios  = POSIX::Termios -> new();
       $termios -> getattr();
       $term     = Term::Cap -> Tgetent({OSPEED => $termios -> getospeed});
       $term    -> Tputs('cl', 1, *STDOUT);
}
# "-----------------------------------------------------------------------------------------------------"
#
# sub: r_log
#
# params
#
#   $lvl: the loglevel (LOG_L_XXX)
#   $msg: the message to log
#
sub r_log {
    my $lvl = shift;
    my $msg = shift;
    if (defined $logfile && $lvl <= $loglevel) {
        my $fmt = "%s:%s:";
        if (index($msg, "\n") != -1) {
            $fmt .= "\n%s\n";
        } else {
            $fmt .= " %s\n";
        }
        chomp($msg);
        printf $logfile $fmt, strftime('%Y-%m-%d %H:%M:%S',localtime()), $loglevel_d[$lvl], $msg;
    }
}
# "-----------------------------------------------------------------------------------------------------"
#
# sub: r_printerr
#
# params
#
#   $msg: the error message to display
#
sub r_printerr {
    my $msg = shift;
    printf STDERR "%s: %s\n", $loglevel_d[LOG_L_ERROR], $msg;
    r_log(LOG_L_ERROR, $msg);
}
# "-----------------------------------------------------------------------------------------------------"
#
# sub: r_print
#
# params
#
#   $msg: the message to display
#
sub r_print {
    my $msg = shift;
    printf "%s: %s\n", $loglevel_d[LOG_L_INFO], $msg;
    r_log(LOG_L_INFO, $msg);
}
# "-----------------------------------------------------------------------------------------------------"
#
# sub: r_exec
#
# params
#
#   $cmd: the command to execute
#
# return
#
#   $ret: the return code
#   $out: single-line output of the program
#
sub r_exec {
    my $cmd = shift;
    my $out;
    my $ret;
    $out = qx($cmd);
#    my @files = ();
#    open my $proc_fh, "$cmd |";
#    while (<$proc_fh>) {
#        $out .= $_;
#        print $_;
#    }
    $ret = $? >> 8;
#    close $proc_fh;
    return ($ret, $out);
}
# "-----------------------------------------------------------------------------------------------------"
#
# sub: r_sqlplus
#
# params
#
#   $sqlfile: the sqlfile to execute
#   $oh     : the oracle home
#   $sid    : the oracle sid
#   $params : params for the sqlfile
#
# return
#
#   $ret: the return code
#   $out: single-line output of the program
#
sub r_sqlplus {
    my $sqlfile = shift;
    my $oh      = shift;
    my $sid     = shift;
    my $params  = shift;
    my $sqlcmd;
       $sqlcmd  = sprintf("export ORACLE_HOME=%s; export ORACLE_SID=%s; \$ORACLE_HOME/bin/sqlplus -S /nolog @%s %s", $oh, $sid, $sqlfile, $params);
    return r_exec($sqlcmd);
}
# "-----------------------------------------------------------------------------------------------------"
#
# sub: r_mkpath
#
# params
#
#   $dir: the path to create
#
sub r_mkpath {
    my $dir = shift;
    my @dirs;
    my $path = '';
       $dir  =~ s/^\///;
       @dirs = split('/', $dir);
    for my $node (@dirs) {
        $path .= '/' . $node;
        unless (-d $path) {
            if (!mkdir ($path)) {
                r_printerr (sprintf("Failed to create directory: %s: %s", $path, $!));
                return 0;
            }
        }
    }
    return 1;
}
# "-----------------------------------------------------------------------------------------------------"
#
# sub: r_log_gi_env
#
# params
#
sub r_log_gi_env {
    my @envs = ('ORACLE_BASE', 'ORACLE_HOME', '_MY_NODE', 'PATH');
    my $envout = "Current Grid Infrastructure environment:\n";
    for my $env (@envs) {
        $envout .= sprintf("%-20s: %s\n", $env, $ENV{$env})
    }
    r_log(LOG_L_DEBUG, $envout);
}
#
# sub: r_init_gi_env
#
# params
#
sub r_init_gi_env {
    my $olr;
    my $orabase;
    my $node;
    unless (-e OLRLOC) {
        r_printerr("OLR-Pointer could not be found: " . OLRLOC);
        exit 1;
    }
    if (!open($olr, '<', OLRLOC)) {
        r_printerr("OLR-Pointer could not be opened: " . $!);
        exit 1;
    }
    while (<$olr>) {
        chomp($_);
        if ( $_ =~ /^crs_home/ ) {
            my (undef, $home) = split('=', $_);
            $ENV{ORACLE_HOME} = $home;
            $ENV{PATH} = $ENV{PATH} . ":" . $home . "/bin";
        }
    }
    unless (defined $ENV{ORACLE_HOME}) {
        r_printerr("crs_home not defined in " . OLRLOC);
        exit 1;
    }
    $orabase = $ENV{ORACLE_HOME} . "/bin/" . ORABASE;
    unless (-x $orabase) {
        r_printerr("orabase cannot not be executed (" . $orabase . ")");
        exit 1;
    }
    (undef, $orabase) = r_exec($orabase);
    chomp($orabase);
    $ENV{ORACLE_BASE} = $orabase;
    unless (-d $ENV{ORACLE_BASE}) {
        r_printerr("ORACLE_BASE cannot be found (" . $ENV{ORACLE_BASE} .")");
        exit 1;
    }
    (undef, $node) = r_exec(OLSNODES . " -l");
    chomp($node);
    $ENV{_MY_NODE} = $node;
    r_log_gi_env();
}
#
# sub: r_parse_args
#
# params
#
#   @argl: arguments to parse
#
# return
#
#   %argdict: arguments in dictionary
#
sub r_parse_args {
    my @argl = @_;
    my $arg = shift(@argl);
    my $parg;
    my %argdict = ();
    while (defined $arg) {
        if ($arg =~ /^-/) {
            $argdict{$arg} = undef;
            $parg = $arg;
        } elsif (defined $parg) {
            $argdict{$parg} = $arg;
            $parg = undef;
        }
        $arg = shift(@argl);
    }
    return %argdict;
}
#
# sub: r_password_encode
#
# params
#
#   $pass: the password to encode
#
# return
#
#   $pass: the encoded password
#
sub r_password_encode {
    my $pass = shift;
    return unpack('H*', $pass);
}
#
# sub: r_password_decode
#
# params
#
#   $pass: the password to decode
#
# return
#
#   $pass: the decoded password
#
sub r_password_decode {
    my $pass = shift;
    return pack('H*', $pass);
}
#
# sub: r_ask_password
#
# params
#
#   $prompt: the prompt to display before password without colon
#
# return
#
#   $pass: the password
#
sub r_ask_password {
    my $prompt = shift;
    my $pass;
    my $ppass;
    $prompt =~ s/\:\s*$//;
    while (1) {
        my $pout;

        if (defined($ppass))
        {
            $pout = sprintf("%s (retype): ", $prompt);
        } else
        {
            $pout = sprintf("%s         : ", $prompt);
        }
        print $pout;
        system('stty -echo');
        chomp($pass = <STDIN>);
        system('stty echo');
        print("\n");
        if (defined($ppass) && $ppass eq $pass)
        {
            last;
        }
        elsif (defined($ppass))
        {
            print STDERR "ERROR: passwords do not match.\n";
            undef($pass);
            undef($ppass);
            next;
        }
        $ppass = $pass;
        undef($pass);
    }
    return $pass;
}
#
# sub: r_check_args
#
# params
#
#   $gargs: arguments given
#   $vargs: valid arguments
#
# return
#
#   $arg: first invalid argument
#
sub r_check_args {
    my ($gargs, $vargs) = @_;
    foreach my $arg (@$gargs) {
        if(!grep(/^$arg$/, @$vargs)) {
            return $arg;
        }
    }
    return undef;
}
####################
# SECTION: INSTALL #
####################
#
# sub: print_install_help
#
# params
#
#   $file: filename of the invoked program
#
sub print_install_help {
    my $file = shift;
    print "\n";
    printf "usage: %s [-i | -emcli [-b <basepath>]] [-h]\n\n", $file;
    printf "\t-i    : install %s\n", PROGNAME;
    printf "\t-emcli: install emcli\n";
    printf "\t-b    : operate in path <basepath>\n";
    printf "\t-h    : print this help\n";
    print "\n";
}
#
# sub: deploy
#
# params
#
#   @argl: arguments for deployment
#
sub deploy {
    my @argl = @_;
    my $param = shift(@argl);
    my @dirs;
    my $base;
    my $ipath;
    my $nodelete = 0;
    while (defined $param) {
        if ($param eq "-b") {
            $base = shift(@argl);
        } elsif ($param eq '-nodelete') {
            $nodelete = 1;
        }
        $param = shift(@argl);
    }
    unless (defined $base) {
        r_printerr("No basepath specified");
        exit 1;
    }
    $ipath = $base . INSTALLPATH;
    @dirs = ($ipath . "/bin", $ipath . "/scripts", $ipath . "/log");
    for my $dir (@dirs) {
        r_print(sprintf("Creating directory %s", $dir));
        r_mkpath($dir);
        unless (-d $dir) {
            r_printerr("Failed to deploy");
            exit 1;
        }
    }
    r_print(sprintf("Copying %s to %s", $0, $ipath . "/bin"));
    if (!copy($0, sprintf("%s/bin/%s", $ipath, PROGNAME))) {
        r_printerr($!);
        r_printerr("Failed to deploy");
        exit 1;
    }
    unless ($nodelete) {
        # make sure /tmp is clean if $0 was copied
        unlink($0);
    }
    r_print(sprintf("Setting correct permissions on %s", $ipath . "/bin/" . PROGNAME));
    if (!chmod(0755, sprintf("%s/bin/%s", $ipath, PROGNAME))) {
        r_printerr($!);
        r_printerr("Failed to deploy");
        exit 1;
    }
    r_print(sprintf("Creating SQL-Scripts in %s/scripts", $ipath));
    while (my ($sqlfile, $sqlcontent) = each(%sqlfiles)) {
        $sqlfile = sprintf("%s/scripts/%s", $ipath, $sqlfile);
        if (!open(RF, '>', $sqlfile)) {
            r_printerr($!);
            r_printerr("Failed to deploy");
            exit 1;
        }
        print RF $sqlcontent;
        close RF;
    }
    print "\n";
    r_print(sprintf("Deployment complete on %s", $ENV{_MY_NODE}));
}
#
# sub: deploy_crs_types
#
# params
#
#   $ipath: rcctl installation path
#
sub deploy_crs_types {
    my $ipath = shift;
    my $attrs;
    my $out;
    my $attr;
    for my $type (@crs_types) {
        (undef, $out) = r_exec(sprintf("%s stat type %s | grep ^TYPE_NAME", CRSCTL, $type->{name}));
        if (length($out) == 0) {
            r_print(sprintf("Adding cluster resource type %s", $type->{name}));
            (undef, $out) = r_exec(sprintf("%s add type %s -basetype %s", CRSCTL, $type->{name}, $type->{basetype}));
            print $out;
        }
        r_print(sprintf("Configuring default attributes for type %s", $type->{name}));
        $attrs = $type->{attrs};
        for $attr (@$attrs) {
            (undef, $out) = r_exec(sprintf("%s modify type %s -attr \"%s\"", CRSCTL, $type->{name}, $attr));
            print $out;
        }
    }
    $attrs = [(sprintf("ATTRIBUTE=ACTION_SCRIPT,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=%s/bin/%s", $ipath, PROGNAME),
               sprintf("ATTRIBUTE=USR_SCRIPT_DIR,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=%s/scripts", $ipath),
               sprintf("ATTRIBUTE=USR_LOG_DIR,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=%s/log", $ipath))];
    r_print(sprintf("Configuring system specific attributes for type %s", CRS_RCCTL_BASETYPE));
    for $attr (@$attrs) {
        (undef, $out) = r_exec(sprintf("%s modify type %s -attr \"%s\"", CRSCTL, CRS_RCCTL_BASETYPE, $attr));
        print $out;
    }
}
#
# sub: install_crs_types
#
# params
#
#   $ipath: rcctl installation path
#
sub install_crs_types {
    my @argl = @_;
    my $param = shift(@argl);
    my $base;
    my $ipath;
    while (defined $param) {
        if ($param eq "-b") {
            $base = shift(@argl);
        }
        $param = shift(@argl);
    }
    unless (defined $base) {
        r_printerr("No basepath specified");
        exit 1;
    }
    $ipath = $base . INSTALLPATH;
    deploy_crs_types($ipath);
}
use constant EMCLIKIT_PATH => "/em/public_lib_download/emcli/kit/emclikit.jar";
#
# sub: deploy_emcli
#
# params
#
#   @argl: arguments for emcli deployment
#
sub deploy_emcli {
    my @argl = @_;
    my $emclidir = shift(@argl);
    my $agentpath = shift(@argl);
    my $omshost = shift(@argl);
    my $omsport = shift(@argl);
    my $omsuser = shift(@argl);
    my $omspass = shift(@argl);
    my $emclikitjar = "/tmp/emclikit.jar";
    my $emclikiturl = sprintf("https://%s:%s/%s", $omshost, $omsport, EMCLIKIT_PATH);
    my ($ret, $out) = r_exec(sprintf("wget --no-check-certificate -O %s %s 2>&1", $emclikitjar, $emclikiturl));
    if ($ret != 0) {
        r_printerr(sprintf("Cannot download emclikit: %s", $out));
        exit 1;
    }
    $ENV{JAVA_HOME} = $agentpath . "/jdk";
    r_print(sprintf("Creating directory %s", $emclidir));
    r_mkpath($emclidir);
    ($ret, $out) = r_exec(sprintf("%s/bin/java -jar %s client -install_dir=%s", $ENV{JAVA_HOME}, $emclikitjar, $emclidir));
    if ($ret != 0) {
        r_printerr(sprintf("Failed to install emcli: %s", $out));
        exit 1;
    }
    my $setup_cmd = "%s/emcli setup -url=https://%s:%s/em -username=%s -password=%s -dir=%s -nocertvalidate -trustall -autologin";
    $setup_cmd = sprintf($setup_cmd, $emclidir, $omshost, $omsport, $omsuser, $omspass, $emclidir);
    r_log(LOG_L_DEBUG, $setup_cmd);
    ($ret, $out) = r_exec($setup_cmd);
    if ($ret != 0) {
        r_printerr(sprintf("Failed to setup emcli: %s", $out));
        exit 1;
    }
}
#
# sub: install_emcli
#
# params
#
#   @argl: arguments for emcli install
#
sub install_emcli {
    my @argl = @_;
    my $param = shift(@argl);
    my $base;
    my $fh;
    my $agentpath;
    my $agentinst;
    my $omshost;
    my $omsport;
    while (defined $param) {
        if ($param eq "-b") {
            $base = shift(@argl);
        }
        $param = shift(@argl);
    }
    unless (defined $base) {
        $base = $ENV{ORACLE_BASE};
    }
    # First, let's find the installation directory of the agent
    if (!open($fh, '<', ORAGCHOMELIST)) {
        r_printerr(sprintf("Cannot open %s: %s", ORAGCHOMELIST, $!));
        exit 1;
    }
    while (<$fh>) {
        my $home;
        my $inst;
        my $line = $_;
        chomp($line);
        ($home, $inst) = split(':', $line);
        if (defined($inst) and $inst =~ /agent_inst$/) {
            $agentpath = $home;
            $agentinst = $inst;
        }
        if (defined $agentpath) {
            last;
        }
    }
    if (!defined($agentpath)) {
        r_printerr("Cannot find enterprise manager agent installation");
        exit 1;
    }
    # Now let's read the configuration and determine the enterprise manager oms host
    if (!open($fh, '<', sprintf("%s/sysman/config/emd.properties", $agentinst))) {
        r_printerr("Can't open file %s: %s", , $!);
        exit 1;
    }
    use URI;
    while (<$fh>) {
        my $line = $_;
        chomp($line);
        if ($line =~ /^REPOSITORY_URL=/) {
            my ($param, $url) = split('=', $line);
            my $uri;
            $uri = URI->new($url);
            $omshost = $uri->host;
            $omsport = $uri->port;
        }
    }
    if (!defined($omshost) || !defined($omsport)) {
        r_printerr("Cannot get enterprise manager repository from configuration");
        exit 1;
    }
    r_print(sprintf("Found oms host: %s", $omshost));
    # We need some login information to connect to the oms
    print "Enter username for enterprise manager: ";
    my $omsuser = <STDIN>;
    chomp($omsuser);
    my $omspass = r_ask_password(sprintf("Enter password for enterprise manager user [%s]: ", $omsuser));
    my (undef, $nodelist) = r_exec(OLSNODES);
    my @nodes = split("\n", $nodelist);
    my $instbin = "/tmp/" . PROGNAME . ".install.pl";
    my $emclipath = $base . INSTALLPATH . "/emcli";
    print "\n";
    r_print(sprintf("Starting emcli deployment in %s on nodes: %s", $base, join(",", @nodes)));
    for my $node (@nodes) {
        my $out;
        print "\n";
        r_print(sprintf("Copying <%s> to <%s:%s>...", $0, $node, $instbin));
        (undef, $out) = r_exec(sprintf("scp %s %s:%s > /dev/null", $0, $node, $instbin));
        print $out;
        r_print(sprintf("Starting deployment on <%s>...", $node));
        my $instargs = "-emclideploy '%s' '%s' '%s' '%s' '%s' '%s'";
        $instargs = sprintf($instargs, $emclipath, $agentpath, $omshost, $omsport, $omsuser, $omspass);
        (undef, $out) = r_exec(sprintf('ssh %s "RCCTL_LOGLEVEL=%s /usr/bin/env perl %s %s 2>&1"', $node, $loglevel, $instbin, $instargs));
        print $out;
    }
    # register the attributes in base type for emcli
    my @attrs = (sprintf("ATTRIBUTE=USR_EMCLI,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=%s/emcli", $emclipath),
                 sprintf("ATTRIBUTE=USR_EMCLI_JDK,TYPE=string,FLAGS=REQUIRED,DEFAULT_VALUE=%s/jdk", $agentpath));
    r_print(sprintf("Configuring emcli specific attributes for type %s", CRS_RCCTL_BASETYPE));
    for my $attr (@attrs) {
        my (undef, $out) = r_exec(sprintf("%s modify type %s -attr \"%s\"", CRSCTL, CRS_RCCTL_BASETYPE, $attr));
        print $out;
    }
}
#
# sub: install
#
# params
#
#   @argl: arguments for install
#
sub install {
    my @argl = @_;
    my $param = shift(@argl);
    my $base;
    my $nodelist;
    my @nodes;
    my $ipath;
    my $skipcrs = 0;
    my $instbin = "/tmp/" . PROGNAME . ".install.pl";
    while (defined $param) {
        if ($param eq "-b") {
            $base = shift(@argl);
        } elsif ($param eq '-skipcrs') {
            $skipcrs = 1;
        }
        $param = shift(@argl);
    }
    unless (defined $base) {
        $base = $ENV{ORACLE_BASE};
    }
    (undef, $nodelist) = r_exec(OLSNODES);
    @nodes = split("\n", $nodelist);
    print "\n";
    r_print(sprintf("Starting install in %s on nodes: %s", $base, join(",", @nodes)));
    for my $node (@nodes) {
        my $out;
        print "\n";
        r_print(sprintf("Copying <%s> to <%s:%s>...", $0, $node, $instbin));
        (undef, $out) = r_exec(sprintf("scp %s %s:%s > /dev/null", $0, $node, $instbin));
        print $out;
        r_print(sprintf("Starting deployment on <%s>...", $node));
        (undef, $out) = r_exec(sprintf('ssh %s "RCCTL_LOGLEVEL=%s /usr/bin/env perl  %s -deploy -b %s 2>&1"', $node, $loglevel, $instbin, $base));
        print $out;
    }
    $ipath = $base . INSTALLPATH;
    if (!$skipcrs) {
        print "\n";
        r_print(sprintf("Configuring %s in cluster registry", PROGNAME));
        print "\n";
        deploy_crs_types($ipath);
    }
    if (not -l sprintf('/usr/local/bin/%s', PROGNAME)) {
        print "\n";
        r_print(sprintf("It is recommended to create a symlink for %s in /usr/local/bin on every node:", PROGNAME));
        r_print("");
        r_print(sprintf("\t# ln -sf %s/bin/%s /usr/local/bin/%s", $ipath, PROGNAME, PROGNAME));
        print "\n";
    }
    print "\n";
    r_print(sprintf("Installation of %s completed.", PROGNAME));
    print "\n";
}
#######################
# SECTION: AGENT MODE #
#######################
use constant CLSAGFW_AE_SUCCESS        => 0;
use constant CLSAGFW_AE_FAIL           => 1;
use constant CLSAGFW_ONLINE            => 0;
use constant CLSAGFW_UNPLANNED_OFFLINE => 1;
use constant CLSAGFW_PLANNED_OFFLINE   => 2;
use constant CLSAGFW_UNKNOWN           => 3;
use constant CLSAGFW_PARTIAL           => 4;
use constant CLSAGFW_FAILED            => 5;
#
# sub: r_agent_state
#
# params
#
#   $state: the agent state
#
sub r_agent_state {
    my $state = shift;
    printf("CRS_STATE_DETAILS:%s\n", $state);
}
#
# sub: r_agent_error
#
# params
#
#   $error: the agent error
#
sub r_agent_error {
    my $error = shift;
    my @lines = split("\n", $error);
    for my $line (@lines) {
        printf("CRS_ERROR:%s: %s\n", uc(PROGNAME), $line);
    }
    r_log(LOG_L_ERROR, $error);
}
#
# sub: r_agent_warning
#
# params
#
#   $warning: the agent warning
#
sub r_agent_warning {
    my $warning = shift;
    my @lines = split("\n", $warning);
    for my $line (@lines) {
        printf("CRS_WARNING:%s: %s\n", uc(PROGNAME), $line);
    }
    r_log(LOG_L_WARNING, $warning);
}
#
# sub: r_agent_progress
#
# params
#
#   $msg: the agent progress
#
sub r_agent_progress {
    my $msg = shift;
    my @lines = split("\n", $msg);
    for my $line (@lines) {
        printf("CRS_PROGRESS:%s: %s\n", uc(PROGNAME), $line);
    }
    r_log(LOG_L_INFO, $msg);
}
#
# sub: r_agent_db_pmon_running
#
# prams
#
#   $sid: oracle sid to check
#
sub r_agent_db_pmon_running {
    my $sid = shift;
    unless(defined $sid) {
        return 0;
    }
    my ($ret, undef) = r_exec(sprintf('pidof ora_pmon_%s', $sid));
    return !$ret;
}
#
# sub: r_agent_check_db_env
#
# return
#
#   CLSAGFW_AE_FAIL on error, CLSAGFW_AE_SUCCESS on success
sub r_agent_check_db_env {
    unless(defined $ENV{_USR_DB_SID}) {
        r_agent_error(sprintf("No oracle sid specified"));
        return CLSAGFW_AE_FAIL;
    }
    unless(defined $ENV{_USR_DB_HOME}) {
        r_agent_error(sprintf("No oracle home specified"));
        return CLSAGFW_AE_FAIL;
    }
    unless(defined $ENV{_USR_DB_USER}) {
        r_agent_error(sprintf("No db user specified"));
        return CLSAGFW_AE_FAIL;
    }
    unless(defined $ENV{_USR_DB_PASS}) {
        r_agent_error(sprintf("No db password specified"));
        return CLSAGFW_AE_FAIL;
    }
    unless(-d $ENV{_USR_DB_HOME}) {
        r_agent_error(sprintf("Invalid oracle home specified: %s", $ENV{_USR_DB_HOME}));
        return CLSAGFW_AE_FAIL;
    }
    my (undef, $out) = r_exec(sprintf('ORACLE_BASE= ORACLE_HOME=%s %s/bin/orabase', $ENV{_USR_DB_HOME}, $ENV{_USR_DB_HOME}));
    chomp($out);
    $ENV{_RCCTL_DB_BASE} = $out;
    unless (-d $ENV{_RCCTL_DB_BASE}) {
        r_agent_error(sprintf("Can't find oracle base: %s", $out));
        return CLSAGFW_AE_FAIL;
    }
    return CLSAGFW_AE_SUCCESS;
}
#
# sub: r_agent_check_env
#
# return
#
#   CLSAGFW_AE_FAIL on error, CLSAGFW_AE_SUCCESS on success
sub r_agent_check_env {
    unless(defined $ENV{_USR_SCRIPT_DIR}) {
        r_agent_error(sprintf("No script directory specified"));
        return CLSAGFW_AE_FAIL;
    }
    unless(defined $ENV{_USR_LOG_DIR}) {
        r_agent_error(sprintf("No log directory specified"));
        return CLSAGFW_AE_FAIL;
    }
    return CLSAGFW_AE_SUCCESS;
}
#
# sub: r_agent_init_env
#
sub r_agent_init_env {
    my $log = "%s/%s.log";
    my $file;
    if (defined($ENV{_USR_DB_SID})) {
        $file = $ENV{_USR_DB_SID};
    } else {
        $file = PROGNAME;
    }
    open $logfile, ">>", sprintf($log, $ENV{_USR_LOG_DIR}, $file);
    $loglevel = LOG_L_INFO;
}
#
# sub: r_agent_emcli_relocate_db
#
sub r_agent_emcli_relocate_db {
    my $targetName = $ENV{_USR_DB_SID};
    $ENV{JAVA_HOME} = $ENV{_USR_EMCLI_JDK};
    if (defined($ENV{_USR_DB_EMCLI_TARGET})) {
        $targetName = $ENV{_USR_DB_EMCLI_TARGET};
    }
    my ($ret, $out) = r_exec("hostname -f 2>&1");
    if ($ret != 0) {
        r_agent_warning("Can't get local hostname: %s", $out);
        return;
    }
    chomp($out);
    my $hostname = $out;
    ($ret, $out) = r_exec(sprintf("%s get_targets -targets=\"%s:%%:oracle_emd\" -format=\"name:csv\" -noheader 2>&1", $ENV{_USR_EMCLI}, $hostname));
    if ($ret != 0) {
        r_agent_warning(sprintf("Can't get agent target for %s: %s", $hostname, $out));
        r_agent_warning(sprintf("%s get_targets -targets=\"%s:%%:oracle_emd\" -format=\"name:csv\" -noheader", $ENV{_USR_EMCLI}, $hostname));
        return;
    }
    chomp($out);
    my (undef, undef, undef, $tagent) = split(',', $out);
    ($ret, $out) = r_exec(sprintf("%s get_targets -targets=\"%s:oracle_database\" -format=\"name:csv\" -noheader", $ENV{_USR_EMCLI}, $targetName));
    chomp($out);
    my (undef, undef, undef, $target) = split(',', $out);
    chomp($target);
    if (!defined($target)) {
        r_agent_warning(sprintf("Can't get database target for %s: %s", $ENV{_USR_DB_SID}, $out));
        r_agent_warning(sprintf("%s get_targets -targets=\"%s:oracle_database\" -format=\"name:csv\" -noheader", $ENV{_USR_EMCLI}, $targetName));
        return;
    }
    ($ret, $out) = r_exec(sprintf("%s relocate_targets -src_agent=currentOwner -dest_agent=\"%s\" -target_name=\"%s\" -target_type=oracle_database -copy_from_src -force=yes -ignoreTimeSkew=yes", $ENV{_USR_EMCLI}, $tagent, $target));
    if ($ret != 0) {
        r_agent_warning(sprintf("Can't relocate database target %s: %s", $target, $out));
        return;
    }
}
#
# sub: agent_check_db
#
sub agent_check_db {
    my $logon;
    my $sqlfile;
    my $state = 'Database stopped';
    my $mstate;
    my $suser = 'sys';
    my $spass = 'sys';
    my $smode = 'as sysdba';
    my %statemap = ('started' => 'nomount', 'mounted' => 'mount', 'open' => 'open');
    if (defined($ENV{_USR_DB_BLACKOUT}) && $ENV{_USR_DB_BLACKOUT} eq '1') {
        r_agent_state('Blackout');
        return CLSAGFW_PARTIAL;
    }
    if (!r_agent_db_pmon_running($ENV{_USR_DB_SID})) {
        r_agent_state($state);
        return CLSAGFW_UNPLANNED_OFFLINE;
    }
    if (lc($ENV{_USR_DB_STARTMODE}) eq 'open') {
        $suser = $ENV{_USR_DB_USER};
        $spass = r_password_decode($ENV{_USR_DB_PASS});
        $smode = '';
    }
    $logon = sprintf("'%s' '%s' '%s'", $suser, $spass, $smode);
    $sqlfile = sprintf("%s/%s", $ENV{_USR_SCRIPT_DIR}, $SCRIPT_DB_STATUS);
    my ($ret, $out) = r_sqlplus($sqlfile, $ENV{_USR_DB_HOME}, $ENV{_USR_DB_SID}, $logon);
#    if ($ret != 0) {
#        r_agent_error(sprintf("Database check failed for instance %s", $ENV{_USR_DB_SID}));
#        r_agent_error(sprintf("Error while executing %s", $sqlfile));
#        r_agent_error($out);
#        return CLSAGFW_FAILED;
#    }

    chomp($out);
    my @statout = grep(!/^$/, split("\n", $out));
    $state = lc($statout[-1]);
    $mstate = $state;
    $state = ucfirst($state);
    if ($#statout > 1) {
        $state = sprintf("%s; %s", $state, join('|', @statout[0 ... ($#statout -1)]));
    }
    r_agent_state($state);
    if (lc($statemap{$mstate}) ne lc($ENV{_USR_DB_STARTMODE}) || $ret != 0) {
        return CLSAGFW_PARTIAL;
    }
    return CLSAGFW_ONLINE;
}
#
# sub: agent_start_db
#
sub agent_start_db {
    my $ret;
    my $out;
    my $sqlfile;
    $ret = agent_check_db();
    if ($ret == CLSAGFW_ONLINE) {
        return CLSAGFW_AE_SUCCESS;
    }
    if ($ret != CLSAGFW_UNPLANNED_OFFLINE) {
        return CLSAGFW_AE_FAIL;
    }
    if (!defined($ENV{_USR_DB_AUDITDEST}) || $ENV{_USR_DB_AUDITDEST} eq '') {
        $ENV{_USR_DB_AUDITDEST} = sprintf('%s/admin/%s/adump', $ENV{_RCCTL_DB_BASE}, $ENV{_USR_DB_SID});
    }
    unless (-d $ENV{_USR_DB_AUDITDEST}) {
        r_agent_progress(sprintf("Creating directory %s", $ENV{_USR_DB_AUDITDEST}));
        r_mkpath($ENV{_USR_DB_AUDITDEST});
    }
    my $initfile = sprintf("%s/dbs/init%s.ora", $ENV{_USR_DB_HOME}, $ENV{_USR_DB_SID});
    my $spfile = sprintf("%s/dbs/spfile%s.ora", $ENV{_USR_DB_HOME}, $ENV{_USR_DB_SID});
    if (-f $spfile) {
        r_agent_warning(sprintf("Using spfile %s", $spfile));
    }
    if (!(-f $initfile)) {
        chomp($ENV{_USR_DB_SPFILE});
        if (!defined($ENV{_USR_DB_SPFILE}) || $ENV{_USR_DB_SPFILE} eq '') {
            r_agent_error(sprintf("No spfile specified and %s does not exist", $initfile));
            return CLSAGFW_AE_FAIL;
        }
        r_agent_progress(sprintf("Creating spfile pointer %s", $initfile));
        my $fh;
        open ($fh, ">", $initfile);
        printf $fh "SPFILE='%s'", $ENV{_USR_DB_SPFILE};
        close($fh);
    }
    r_agent_state('Starting');
    $sqlfile = sprintf("%s/%s", $ENV{_USR_SCRIPT_DIR}, $SCRIPT_DB_STARTUP);
    ($ret, $out) = r_sqlplus($sqlfile, $ENV{_USR_DB_HOME}, $ENV{_USR_DB_SID}, $ENV{_USR_DB_STARTMODE});
    if ($ret != 0) {
        chomp($out);
        r_agent_error(sprintf("Database start failed for instance %s", $ENV{_USR_DB_SID}));
        r_agent_error(sprintf("Error while executing %s", $sqlfile));
        r_agent_error($out);
        return CLSAGFW_AE_FAIL;
    }
    if (defined($ENV{_USR_EMCLI}) && -x $ENV{_USR_EMCLI} && $ENV{_USR_DB_EMCLI_ENABLED} eq '1') {
        r_agent_progress(sprintf("Relocating database %s in oms", $ENV{_USR_DB_SID}));
        r_agent_emcli_relocate_db();
    }
    return CLSAGFW_AE_SUCCESS;
}
#
# sub: agent_clean_db
#
sub agent_clean_db {
    my ($ret, $out) = r_exec(sprintf("pkill -9 -f 'ora.*_%s'", $ENV{_USR_DB_SID}));
    r_agent_warning(sprintf("Killing all proesses for sid %s", $ENV{_USR_DB_SID}));
    sleep(5);
    r_exec("sysresv -f");
    ($ret, $out) = r_exec(sprintf("pgrep -f 'ora.*_%s'", $ENV{_USR_DB_SID}));
    if ($ret != 0) {
        return CLSAGFW_AE_FAIL;
    }
    return CLSAGFW_AE_SUCCESS;
}
#
# sub: agent_stop_db
#
sub agent_stop_db {
    my $ret;
    my $out;
    my $sqlfile;
    my $child_pid;
    if (!r_agent_db_pmon_running($ENV{_USR_DB_SID})) {
        return CLSAGFW_AE_SUCCESS;
    }
    if (!defined($child_pid = fork())) {
        r_agent_error($!);
        return CLSAGFW_AE_FAIL;
    }
    if ($child_pid == 0) {
        # subprocess
        $sqlfile = sprintf("%s/%s", $ENV{_USR_SCRIPT_DIR}, $SCRIPT_DB_SHUTDOWN);
        ($ret, $out) = r_sqlplus($sqlfile, $ENV{_USR_DB_HOME}, $ENV{_USR_DB_SID}, $ENV{_USR_DB_STOPMODE});
        if ($ret != 0) {
            r_agent_error(sprintf("Database stop failed for instance %s", $ENV{_USR_DB_SID}));
            r_agent_error(sprintf("Error while executing %s", $sqlfile));
            r_agent_error($out);
            exit CLSAGFW_AE_FAIL;
        }
        exit CLSAGFW_AE_SUCCESS;
    }
    my $cnt = 0;
    my $cpid;
    my $cret = 0;
    do {
        $cnt++;
        $cpid = waitpid($child_pid, WNOHANG);
        $cret = $? >> 8;
#        $cret = ($cret & 0x80) ? -(0x100 - ($cret & 0xFF)) : $cret;
        if ($cnt > 60) {
            $sqlfile = sprintf("%s/%s", $ENV{_USR_SCRIPT_DIR}, $SCRIPT_DB_SHUTDOWN);
            ($ret, $out) = r_sqlplus($sqlfile, $ENV{_USR_DB_HOME}, $ENV{_USR_DB_SID}, 'abort');
            if ($ret != 0) {
                r_agent_error(sprintf("Database abort failed for instance %s", $ENV{_USR_DB_SID}));
                r_agent_error(sprintf("Error while executing %s", $sqlfile));
                r_agent_error($out);
                return CLSAGFW_AE_FAIL;
            }
            return CLSAGFW_AE_SUCCESS;
        }
        sleep(1);
    } while ($cpid == 0);
    return $cret;
}
#
# sub: agent_check
#
sub agent_check {
    if (r_agent_check_env() != CLSAGFW_AE_SUCCESS) {
        return CLSAGFW_AE_FAIL;
    }
    if (r_agent_check_db_env() != CLSAGFW_AE_SUCCESS) {
        return CLSAGFW_AE_FAIL;
    }
    r_agent_init_env();
    exit agent_check_db();
}
#
# sub: agent_start
#
sub agent_start {
    if (r_agent_check_env() != CLSAGFW_AE_SUCCESS) {
        return CLSAGFW_AE_FAIL;
    }
    if (r_agent_check_db_env() != CLSAGFW_AE_SUCCESS) {
        return CLSAGFW_AE_FAIL;
    }
    r_agent_init_env();
    exit agent_start_db();
}
#
# sub: agent_stop
#
sub agent_stop {
    if (r_agent_check_env() != CLSAGFW_AE_SUCCESS) {
        return CLSAGFW_AE_FAIL;
    }
    if (r_agent_check_db_env() != CLSAGFW_AE_SUCCESS) {
        return CLSAGFW_AE_FAIL;
    }
    r_agent_init_env();
    exit agent_stop_db();
}
#
# sub: agent_clean
#
sub agent_clean {
    if (r_agent_check_env() != CLSAGFW_AE_SUCCESS) {
        return CLSAGFW_AE_FAIL;
    }
    if (r_agent_check_db_env() != CLSAGFW_AE_SUCCESS) {
        return CLSAGFW_AE_FAIL;
    }
    r_agent_init_env();
    exit agent_clean_db();
}
###############################
# SECTION: COMMAND/SHELL MODE #
###############################
#
# sub: db_add
#
# params
#
#   %argd: commandline arguments
#
sub db_add {
    my (%argd) = @_;
    my $db = $argd{'-db'};
    my $add_cmd = '%s add res orcl.%s.db -type %s';
# Arguments will get checked in db_modify
    r_init_gi_env();
    unless (defined $db) {
        r_printerr('No database specified');
        exit 1;
    }
    unless (exists($argd{'-oh'})) {
        r_printerr('No oracle home specified');
        exit 1;
    }
    r_print(sprintf('Adding cluster resource for database %s', $db));
    my ($ret, $out) = r_exec(sprintf($add_cmd, CRSCTL, $db, CRS_RCCTL_DB_TYPE));
    if ($ret != 0) {
        r_printerr(sprintf('Failed to add database cluster resource for database %s', $db));
        print($out);
        exit 1;
    }
    db_modify(%argd);
}
#
# sub: db_stop
#
# params
#
#   %argd: commandline arguments
#
sub db_stop {
    my (%argd) = @_;
    my $db = $argd{'-db'};
    my $stop_cmd = '%s stop res orcl.%s.db';
    my @vargs = ('-db', '-mode', '-f');
    my @gargs = keys(%argd);
    my $iarg = r_check_args(\@gargs, \@vargs);
    if(defined($iarg)) {
        r_printerr(sprintf('Invalid argument: %s', $iarg));
        exit 1;
    }
    r_init_gi_env();
    if (exists($argd{'-all'})) {
        $stop_cmd = sprintf('%s stop res -w \'TYPE = %s\'', CRSCTL, CRS_RCCTL_DB_TYPE);
    } elsif (!defined($db)) {
        r_printerr('No database specified');
        exit 1;
    }
    if (exists($argd{'-mode'})) {
        $stop_cmd = sprintf('%s -env "USR_DB_STOPMODE=%s"', $stop_cmd, $argd{'-mode'});
    }
    if (exists($argd{'-f'})) {
        $stop_cmd = sprintf("%s -f", $stop_cmd);
    }
    my ($ret, $out) = r_exec(sprintf($stop_cmd, CRSCTL, $db));
    if ($ret != 0) {
        r_printerr(sprintf('Failed to stop database %s', $db));
        print($out);
        exit 1;
    }
}
#
# sub: db_start
#
# params
#
#   %argd: commandline arguments
#
sub db_start {
    my (%argd) = @_;
    my $db = $argd{'-db'};
    my $start_cmd = '%s start res orcl.%s.db';
    my @vargs = ('-db', '-mode', '-n', '-f');
    my @gargs = keys(%argd);
    my $iarg = r_check_args(\@gargs, \@vargs);
    if(defined($iarg)) {
        r_printerr(sprintf('Invalid argument: %s', $iarg));
        exit 1;
    }
    r_init_gi_env();
    if (exists($argd{'-all'})) {
        $start_cmd = sprintf('%s start res -w \'TYPE = %s\'', CRSCTL, CRS_RCCTL_DB_TYPE);
    } elsif (!defined($db)) {
        r_printerr('No database specified');
        exit 1;
    }
    if (exists($argd{'-mode'})) {
        $start_cmd = sprintf('%s -env "USR_DB_STARTMODE=%s"', $start_cmd, $argd{'-mode'});
    }
    if (exists($argd{'-n'})) {
        $start_cmd = sprintf('%s -n %s', $start_cmd, $argd{'-n'});
    }
    if (exists($argd{'-f'})) {
        $start_cmd = sprintf("%s -f", $start_cmd);
    }
    my ($ret, $out) = r_exec(sprintf($start_cmd, CRSCTL, $db));
    if ($ret != 0) {
        r_printerr(sprintf('Failed to start database %s', $db));
        print($out);
        exit 1;
    }
}
#
# sub: db_config
#
# params
#
#   %argd: commandline arguments
#
sub db_config {
    my (%argd) = @_;
    my $db = $argd{'-db'};
    my $stat_cmd = '%s stat res orcl.%s.db -p';
    my @attrs = ('USR_DB_SID', 'USR_DB_HOME', 'USR_DB_SPFILE', 'USR_DB_STARTMODE', 'USR_DB_STOPMODE', 'USR_DB_USER', 'USR_DB_AUDITDEST', 'USR_DB_DISKGROUPS', 'PLACEMENT', 'HOSTING_MEMBERS', 'USR_DB_BLACKOUT', 'USR_DB_EMCLI_ENABLED', 'USR_DB_EMCLI_TARGET', 'USR_DB_VIPNAME');
    my @vargs = ('-db');
    my @gargs = keys(%argd);
    my $iarg = r_check_args(\@gargs, \@vargs);
    if(defined($iarg)) {
        r_printerr(sprintf('Invalid argument: %s', $iarg));
        exit 1;
    }
    r_init_gi_env();
    unless (defined $db) {
        r_printerr('No database specified');
        exit 1;
    }
    my ($ret, $out) = r_exec(sprintf($stat_cmd, CRSCTL, $db));
    if ($ret != 0) {
        r_printerr(sprintf('Failed to get config for database %s', $db));
        print($out);
        exit 1;
    }
    my %config = ();
    my @lines = split("\n", $out);
    for my $line (@lines) {
        my ($attr, $value) = split('=', $line);
        $config{$attr} = $value;
    }
    print "\n";
    for my $attr (@attrs) {
        my $value = $config{$attr};
        my $display;
        if (!defined($value)) {
            $value = '';
        }
        if ($attr eq 'USR_DB_SID') {
            $display = 'Oracle SID';
        } elsif ($attr eq 'USR_DB_HOME') {
            $display = 'Oracle Home';
        } elsif ($attr eq 'USR_DB_SPFILE') {
            $display = 'SPFILE';
        } elsif ($attr eq 'USR_DB_STARTMODE') {
            $display = 'Start Mode';
        } elsif ($attr eq 'USR_DB_STOPMODE') {
            $display = 'Stop Mode';
        } elsif ($attr eq 'USR_DB_USER') {
            $display = 'Monitoring User';
        } elsif ($attr eq 'HOSTING_MEMBERS') {
            $display = 'Nodes';
        } elsif ($attr eq 'USR_DB_AUDITDEST') {
            $display = 'Audit Destination';
        } elsif ($attr eq 'PLACEMENT') {
            $display = 'Placement';
        } elsif ($attr eq 'USR_DB_DISKGROUPS') {
            $display = 'Diskgroups';
        } elsif ($attr eq 'USR_DB_VIPNAME') {
            $display = 'VIP-Name';
        } elsif ($attr eq 'USR_DB_EMCLI_ENABLED') {
            $display = 'Emcli';
            $value = ($value eq '1') ? 'enabled' : 'disabled';
        } elsif ($attr eq 'USR_DB_EMCLI_TARGET') {
            $display = 'Emcli Target';
        } elsif ($attr eq 'USR_DB_BLACKOUT') {
            $display = 'Blackout';
            $value = ($value eq '1') ? 'enabled' : 'disabled';
        }
        if (!defined($display)) {
            next;
        }
        printf("%-20s: %s\n", $display, $value);
    }
    print "\n";
}
#
# sub: db_modify
#
# params
#
#   %argd: commandline arguments
#
sub db_modify {
    my (%argd) = @_;
    my $db = $argd{'-db'};
    my $modify_cmd = '%s modify res orcl.%s.db -attr "%s"';
    my @vargs = ('-db', '-oh', '-spfile', '-startmode', '-stopmode', '-user', '-nodes', '-auditdest', '-placement', '-dg', '-emcli', '-emclitarget', '-vipname');
    my @gargs = keys(%argd);
    my $iarg = r_check_args(\@gargs, \@vargs);
    if(defined($iarg)) {
        r_printerr(sprintf('Invalid argument: %s', $iarg));
        exit 1;
    }
    r_init_gi_env();
    unless (defined $db) {
        r_printerr('No database specified');
        exit 1;
    }
    for my $opt (@vargs) {
        unless (exists($argd{$opt})) {
            next;
        }
        my $val = $argd{$opt};
        my $attr;
        if (!defined($val)) {
            r_printerr(sprintf('No value for option \'%s\' specified', $opt));
            exit 1;
        }
        if ($opt eq '-db') {
            $attr = sprintf("USR_DB_SID=%s", $val);
        } elsif ($opt eq '-oh') {
            $attr = sprintf("USR_DB_HOME=%s", $val);
        } elsif ($opt eq '-spfile') {
            $attr = sprintf("USR_DB_SPFILE=%s", $val);
        } elsif ($opt eq '-startmode') {
            $attr = sprintf("USR_DB_STARTMODE=%s", $val);
        } elsif ($opt eq '-stopmode') {
            $attr = sprintf("USR_DB_STOPMODE=%s", $val);
        } elsif ($opt eq '-user') {
            my $pass = r_ask_password(sprintf('Password for %s: ', $val));
            $pass = r_password_encode($pass);
            $attr = sprintf("USR_DB_USER=%s,USR_DB_PASS=%s", $val, $pass);
        } elsif ($opt eq '-nodes') {
            $attr = sprintf("HOSTING_MEMBERS=%s", $val);
        } elsif ($opt eq '-auditdest') {
            $attr = sprintf("USR_DB_AUDITDEST=%s", $val);
        } elsif ($opt eq '-placement') {
            $attr = sprintf("PLACEMENT=%s", $val);
        } elsif ($opt eq '-emcli') {
            $attr = sprintf("USR_DB_EMCLI_ENABLED=%s", $val);
        } elsif ($opt eq '-emclitarget') {
            $attr = sprintf("USR_DB_EMCLI_TARGET=%s", $val);
        # TODO: add/remove_start/stop_dependencies calls
        } elsif ($opt eq '-dg') {
            my @dgs = map { sprintf("ora.%s.dg", $_) } split(' ', $val);
            $attr  = sprintf("USR_DB_DISKGROUPS=%s", $val);
            $val   = join(',', @dgs);
            $attr .= sprintf(",START_DEPENDENCIES='hard(%s) pullup(%s)'", $val, $val);
            $attr .= sprintf(",STOP_DEPENDENCIES='hard(%s)'", $val);
        } elsif ($opt eq '-vipname') {
            $attr  = sprintf("USR_DB_VIPNAME=%s", $val);
            $attr .= sprintf(",START_DEPENDENCIES='hard(orcl.%s.vip) pullup(orcl.%s.vip)'", $val, $val);
            $attr .= sprintf(",STOP_DEPENDENCIES='hard(orcl.%s.vip)'", $val);
        } elsif ($opt eq '') {
            $attr = sprintf("USR_=%s", $val);
        }
        my ($ret, $out) = r_exec(sprintf($modify_cmd, CRSCTL, $db, $attr));
        if ($ret != 0) {
            r_printerr(sprintf('Failed to modify cluster resource for database %s', $db));
            print($out);
            exit 1;
        }
    }
}
#
# sub: db_relocate
#
# params
#
#   %argd: commandline arguments
#
sub db_relocate {
    my (%argd) = @_;
    my $db = $argd{'-db'};
    my $relocate_cmd = '%s relocate res orcl.%s.db';
    my @envs = ();
    my @vargs = ('-db', '-startmode', '-stopmode', '-n', '-f');
    my @gargs = keys(%argd);
    my $iarg = r_check_args(\@gargs, \@vargs);
    if(defined($iarg)) {
        r_printerr(sprintf('Invalid argument: %s', $iarg));
        exit 1;
    }
    r_init_gi_env();
    unless (defined $db) {
        r_printerr('No database specified');
        exit 1;
    }
    if (exists($argd{'-startmode'})) {
        push(@envs, sprintf('USR_DB_STARTMODE=%s', $argd{'-startmode'}));
    }
    if (exists($argd{'-stopmode'})) {
        push(@envs, sprintf('USR_DB_STOPMODE=%s', $argd{'-stopmode'}));
    }
    if (exists($argd{'-n'})) {
        $relocate_cmd = sprintf('%s -n %s', $relocate_cmd, $argd{'-n'});
    }
    if (length(@envs) > 0) {
        $relocate_cmd = sprintf('%s -env "%s"', $relocate_cmd, join(',', @envs));
    }
    if (exists($argd{'-f'})) {
        $relocate_cmd = sprintf("%s -f", $relocate_cmd);
    }
    my ($ret, $out) = r_exec(sprintf($relocate_cmd, CRSCTL, $db));
    if ($ret != 0) {
        r_printerr(sprintf('Failed to relocate database %s', $db));
        print($out);
        exit 1;
    }
}
#
# sub: blackout_start
#
# params
#
#   %argd: commandline arguments
#
sub blackout_start {
    my (%argd) = @_;
    my $db = $argd{'-db'};
    my $blackout_cmd = '%s modify res orcl.%s.db -attr "USR_DB_BLACKOUT=1"';
    my @vargs = ('-db');
    my @gargs = keys(%argd);
    my $iarg = r_check_args(\@gargs, \@vargs);
    if(defined($iarg)) {
        r_printerr(sprintf('Invalid argument: %s', $iarg));
        exit 1;
    }
    r_init_gi_env();
    unless (defined $db) {
        r_printerr('No database specified');
        exit 1;
    }
    my ($ret, $out) = r_exec(sprintf($blackout_cmd, CRSCTL, $db));
    if ($ret != 0) {
        r_printerr(sprintf('Failed to blackout database %s', $db));
        print($out);
        exit 1;
    }
}
#
# sub: blackout_stop
#
# params
#
#   %argd: commandline arguments
#
sub blackout_stop {
    my (%argd) = @_;
    my $db = $argd{'-db'};
    my $blackout_cmd = '%s modify res orcl.%s.db -attr "USR_DB_BLACKOUT=0"';
    my @vargs = ('-db');
    my @gargs = keys(%argd);
    my $iarg = r_check_args(\@gargs, \@vargs);
    if(defined($iarg)) {
        r_printerr(sprintf('Invalid argument: %s', $iarg));
        exit 1;
    }
    r_init_gi_env();
    unless (defined $db) {
        r_printerr('No database specified');
        exit 1;
    }
    my ($ret, $out) = r_exec(sprintf($blackout_cmd, CRSCTL, $db));
    if ($ret != 0) {
        r_printerr(sprintf('Failed to remove blackout for database %s', $db));
        print($out);
        exit 1;
    }
}
#
# sub: db_remove
#
# params
#
#   %argd: commandline arguments
#
sub db_remove {
    my (%argd) = @_;
    my $db = $argd{'-db'};
    my $remove_cmd = '%s delete res orcl.%s.db';
    my @vargs = ('-db', '-f');
    my @gargs = keys(%argd);
    my $iarg = r_check_args(\@gargs, \@vargs);
    if(defined($iarg)) {
        r_printerr(sprintf('Invalid argument: %s', $iarg));
        exit 1;
    }
    r_init_gi_env();
    unless (defined $db) {
        r_printerr('No database specified');
        exit 1;
    }
    if (exists($argd{'-f'})) {
        $remove_cmd = sprintf('%s -f', $remove_cmd);
    }
    my ($ret, $out) = r_exec(sprintf($remove_cmd, CRSCTL, $db));
    if ($ret != 0) {
        r_printerr(sprintf('Failed to remove database %s', $db));
        print($out);
        exit 1;
    }
}
#
# sub: r_print_db_status
#
sub r_print_db_status {
    my @config = @_;
    my @dbs = ();
    my $db;
    my $state_details;
    my $target;
    my $state;
    my $node;
    my $smode;
    my $sid;
    my $out = '';
    my %groups = (
        node => {},
        state => {},
    );
    printf "\n%-12s %-15s %-20s %s\n\n", "Database", "State", "Node", "Details";
    foreach my $line (@config) {
        chomp($line);
        if (defined($sid) && defined($state) && defined($target) &&
            defined($node) && defined($state_details)) {
               my $color;
               if ($state eq $target and $state eq "ONLINE") {
                   $color = "green";
               } elsif ($state eq "OFFLINE") {
                   $color = "red";
               } else {
                   $color = "yellow";
               }
               printf "%-12s %s %-20s %s\n", $sid, colored ([ $color ], sprintf("%-15s", $state)), $node, $state_details;
               undef($sid);
               undef($state);
               undef($node);
               undef($target);
               undef($state_details);
               next;
        }
        my ($attr, $value) = split('=', $line);
        unless (defined($attr)) {
            next;
        }
        if ($attr eq 'NAME') {
            $db = {};
            push(@dbs, $db);
            (undef, $sid, undef) = split('\.', $value);
            $db->{sid} = $sid;
        } elsif ($attr eq 'STATE_DETAILS') {
            $db->{state_details} = ($value eq '') ? 'UNKNOWN' : $value;
        } elsif ($attr eq "LAST_SERVER") {
            $db->{node} = $value;
            $groups{node}->{$value} = 1;
        } elsif ($attr eq "USR_DB_STARTMODE") {
            $db->{smode} = $value;
        } elsif ($attr eq "STATE") {
            ($db->{state}, undef) = split(' ', $value);
        } elsif ($attr eq "TARGET") {
            $db->{target} = $value;
        }
    }
    foreach $db (@dbs) {
       my $color;
        if ($db->{state} eq $db->{target} and $db->{state} eq "ONLINE") {
           $color = "green";
        } elsif ($db->{state} eq "OFFLINE") {
           $color = "red";
        } else {
           $color = "yellow";
        }
        $out .= sprintf("%-12s %s %-20s %s\n", $db->{sid}, colored ([ $color ], sprintf("%-15s", $db->{state})), $db->{node}, $db->{state_details});
    }
    print $out;
    print "\n";
}
#
# sub: resource_status
#
sub resource_status {
    my (%argd) = @_;
    my $loop = 0;
    my @vargs = ('-watch');
    my @gargs = keys(%argd);
    my $iarg = r_check_args(\@gargs, \@vargs);
    if(defined($iarg)) {
        r_printerr(sprintf('Invalid argument: %s', $iarg));
        exit 1;
    }
    r_init_gi_env();
    if (exists($argd{'-watch'})) {
        $loop = 1;
    }
    do {
        r_exec(sprintf("%s check res -w 'TYPE = %s'", CRSCTL, CRS_RCCTL_DB_TYPE));
        select(undef, undef, undef, 0.5);
        my (undef, $out) = r_exec(sprintf("%s stat res -v -w 'TYPE = %s'", CRSCTL, CRS_RCCTL_DB_TYPE));
        my @config = split("\n", $out);
        if ($loop) {
            r_clrscr();
        }
        if (@config > 0) {
            r_print_db_status(@config);
        } else {
            r_print("No databases configured");
        }
        if ($loop) {
            sleep(2);
        }
    } while ($loop);
}
#################
# SECTION: MAIN #
#################
my %helpd = ();
$helpd{'clean'}{''} =
    "\nCRS ONLY\n\n";
$helpd{'start'}{''} =
    "\nCRS ONLY, see start <obj>\n\n";
$helpd{'stop'}{''} =
    "\nCRS ONLY, see stop <obj>\n\n";
$helpd{'check'}{''} =
    "\nCRS ONLY\n\n";
$helpd{'status'}{''} =
    "\n" .
    "%s status\n\n" .
    "    Print status for all managed ressources\n\n" .
    "        [-watch]: status will be refreshed every 3 seconds\n" .
    "\n";
$helpd{'start'}{'blackout'} =
    "\n" .
    "%s start blackout ...\n\n" .
    "    Starts a blackout\n\n" .
    "        -db <db>: the database to put in blackout mode\n" .
    "\n";
$helpd{'stop'}{'blackout'} =
    "\n" .
    "%s stop blackout ...\n\n" .
    "    Stops a blackout\n\n" .
    "        -db <db>: the database to put out of blackout mode\n" .
    "\n";
$helpd{'start'}{'database'} =
    "\n" .
    "%s start database ...\n\n" .
    "    Starts a database\n\n" .
    "        -db <db> | -all: the database to start or all\n" .
    "        [-f]           : force start for dependencies\n" .
    "        [-n <node>]    : the cluster node to start on\n" .
    "        [-mode <mode>] : the startup mode to use (open|nomount|mount])\n" .
    "\n";
$helpd{'stop'}{'database'} =
    "\n" .
    "%s stop database ...\n\n" .
    "    Stops a database\n\n" .
    "    Arguments:\n" .
    "        -db <db> | -all: the database to stop or all\n" .
    "        [-f]           : force stop for dependencies\n" .
    "        [-mode <mode>] : the shutdown mode to use (immediate|transactional|abort)\n" .
    "\n";
my $helpd_add_oopts =
    "        [-spfile <spfile>]      : spfile location (e.g. +DATA/<db>/spfile<db>.ora)\n" .
    "        [-startmode <mode>]     : default start mode ([open]|nomount|mount)\n" .
    "        [-stopmode <mode>]      : default stop mode ([immediate]|transactional|abort)\n" .
    "        [-user <user>]          : the monitoring user (dbsnmp/dbsnmp)\n" .
    "        [-nodes '<nodelist>']   : nodelist for placement, space separated\n" .
    "        [-dg '<diskgroups>']    : diskgroups for dependency list, space separated\n" .
    "        [-auditdest <auditdest>]: audit directory location (\$ORACLE_BASE/admin/<db>/adump)\n" .
    "        [-placement <placement>]: placement policy (favored|restricted)\n" .
    "        [-emcli <0|1>]          : emcli usage ([0]|1)\n" .
    "        [-emclitarget <target>] : emcli target name\n" .
    "        [-vipname <vip>]        : vip name\n";
$helpd{'add'}{'database'} =
    "\n" .
    "%s add database ...\n\n" .
    "    Adds a database\n\n" .
    "        -db <db>                : the database sid to add\n" .
    "        -oh <home>              : the oracle home of the database\n" .
    $helpd_add_oopts .
    "\n";
$helpd{'remove'}{'database'} =
    "\n" .
    "%s remove database ...\n\n" .
    "    Removes a database\n\n" .
    "        -db <db>: the database sid to remove\n" .
    "        [-f]    : force removal, if db is running\n" .
    "\n";
$helpd{'modify'}{'database'} =
    "\n" .
    "%s modify database ...\n\n" .
    "    Changes configuration of a database\n\n" .
    "        -db <db>                : the database sid to add\n" .
    "        [-oh <home>]            : the oracle home of the database\n" .
    $helpd_add_oopts .
    "\n";
$helpd{'relocate'}{'database'} =
    "\n" .
    "%s relocate database ...\n\n" .
    "    Relocates a database from one server to another\n\n" .
    "        -db <db>           : the database to relocate\n" .
    "        [-n <node>]        : the cluster node to start on\n" .
    "        [-f]               : force relocate for dependencies\n" .
    "        [-startmode <mode>]: start mode (open|nomount|mount)\n" .
    "        [-stopmode <mode>] : stop mode (immediate|transactional|abort)\n" .
    "\n";
sub help_command {
    my $cmd = shift;
    my $obj = shift;
    if (!exists($helpd{$cmd}{$obj})) {
        r_printerr(sprintf("No help topic for %s %s", $cmd, $obj));
        exit 1;
    }
    printf($helpd{$cmd}{$obj}, PROGNAME);
}
sub help {
    printf "\n%s release %s\n\n", PROGNAME, RELEASE;
    printf "Usage:\n";
    printf "    %s <command> [<object>] [<args>]\n\n", PROGNAME;
    printf "Commands:\n";
    my @commands = sort(keys(%installedptr));
    printf "    %s\n\n", join('|', @commands);
    printf "Ojects:\n";
    my @objects = ();
    for my $command (@commands) {
        for my $obj (keys(%{$installedptr{$command}})) {
            if (grep($_ eq $obj, @objects) || $obj eq '') {
                next;
            }
            push(@objects, $obj);
        }
    }
    printf "    %s\n\n", join('|', @objects);
    printf "For help of a specific command use %s <command> [<object>] -h\n\n", PROGNAME;
}
sub main_installed {
    my @argl = @_;
    my %argdict;
    my $cmd = shift(@argl);
    my $obj;
    my $func;
    unless (defined $cmd) {
        r_printerr("No command specified");
        exit 1;
    }
    if ($cmd eq '-h') {
        help();
        exit 0;
    }
    unless (exists($installedptr{$cmd})) {
        r_printerr("Invalid command specified");
        exit 1;
    }
    $obj = shift(@argl);
    if (!defined($obj) && exists($installedptr{$cmd}{''})) {
        $obj = '';
    } elsif (!defined($obj)) {
        r_printerr("No object specified");
        exit 1;
    }
    if (substr($obj, 0, 1) eq '-') {
        push(@argl, $obj);
        $obj = '';
    }
    if (exists($objaliases{$obj})) {
        $obj = $objaliases{$obj};
    }
    if (!exists($installedptr{$cmd}{$obj})) {
        r_printerr(sprintf("Invalid object specified for command %s", $cmd));
        r_printerr(sprintf('Valid objects are: %s', join(', ', grep(/^.+$/, keys(%{$installedptr{$cmd}})))));
        exit 1;
    }
    %argdict = r_parse_args(@argl);
    if (exists($argdict{'-h'})) {
        help_command($cmd, $obj);
        exit 0;
    }
    $func = $installedptr{$cmd}{$obj};
    &{$func}(%argdict);
}
sub main_installer {
    my $file = shift;
    my @argl = @_;
    my $func;
    my $arg = shift(@argl);
    my $logname = '/tmp/' . PROGNAME . '.install.log';
    r_print("Logging to file " . $logname);
    open $logfile, ">>", $logname;
    r_init_gi_env();
    unless (defined $arg) {
        r_printerr("No parameter specified");
        print_install_help($file);
        exit 1;
    }
    $func = $installptr{$arg};
    unless (defined $func) {
        r_printerr("Invalid parameter specified: " . $arg);
        print_install_help($file);
        exit 1;
    }
    if ($arg eq '-h') {
        push(@argl, $file);
    }
    &{$func}(@argl);
}
sub main {
    my @argl = @_;
    my $self = File::Spec->rel2abs($0);
    my ($vol, $dir, $file) = File::Spec->splitpath($self);
    if (defined $ENV{RCCTL_LOGLEVEL}) {
        $loglevel = $ENV{RCCTL_LOGLEVEL};
    }
    if ($file eq PROGNAME) {
        main_installed(@argl);
    } elsif ($file eq sprintf("%s.install.pl", PROGNAME)) {
        main_installer($file, @argl);
    } else {
        r_printerr(sprintf("Invalid invocation of %s: %s", PROGNAME, $file));
        exit 1;
    }
}
main(@ARGV);
