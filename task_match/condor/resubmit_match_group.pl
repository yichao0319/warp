#!/bin/perl

use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use strict;
use POSIX;

#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output


#############
# Constants
#############
my $VALIDATE = "validate_err_match_group.sh";
my $RERUN    = "rerun.sh";

#############
# Variables
#############
my $max_jobs = 70;
my @priority = ("1.condor", "condor_submit");
my $remain_jobs = 1;


#############
## main start
#############
while($remain_jobs > 0) {
    my $cmd = "condor_q | grep yichao | wc -l";
    my $num_running = `$cmd` + 0;
    my $quata = $max_jobs - $num_running;
    print "# running jobs: $num_running\n";
    print "Quata: $quata\n";

    $remain_jobs = 0;


    foreach my $this_priority (@priority) {
        print "keyword: $this_priority\n";

        $cmd = "bash $VALIDATE | grep $this_priority | wc -l";
        my $num_keyword_job = `$cmd` + 0;
        $remain_jobs += $num_keyword_job;
        print "  # keyword jobs = $num_keyword_job\n";

        my $num_to_run = min($quata, $num_keyword_job);
        print "  # rerun = $num_to_run\n";

        while($num_to_run > 0) {
            $remain_jobs --;
            $num_to_run --;

            $cmd = "bash $VALIDATE | grep $this_priority | head -1";
            my $condor_cmd = `$cmd`;
            $condor_cmd =~ s/'/\\'/g;

            print "  > $condor_cmd";
            `$condor_cmd 2> /dev/null`;
            # exit
            
            $num_running ++;
            sleep(2);
        }
    }

    print "# remaining jobs = $remain_jobs\n";
    sleep(60);
}
print ">>>> end of works :D\n";
