#!/usr/bin/perl

use strict;

my $seqname = "";
my $seq_dir = "";

my $this_dir = `pwd`;

if( $this_dir =~ /(.+)\/auto_pilot/ ){
	$seq_dir = $1;
}else{
	print "ERROR! THIS SCRIPT MUST RUN ON \'AUTO_PILOT\' DIRECTORY !!\n";
	exit(1);
};

print "\n";
print "Sequence Directory: $seq_dir\n";
print "\n";

convert_testunits_from_bzr_to_git($seq_dir);

exit(0);


############################### SUBROUTINES #################################

sub convert_testunits_from_bzr_to_git{
	
	my $target_dir = shift @_;
	my $temp_list = `ls ..`;
	my @testunit_list = split(" ",$temp_list); 

	print "\n";
	print "#####################################################################################\n";
	print "Scanning Directory $target_dir for Test Units\n";
	print "#####################################################################################\n";
	print "\n";
	print "\n";

	my $not_converted = "";

	foreach my $tunit (@testunit_list){
		print "TEST UNIT $tunit\n";
	
		if( $tunit ne "auto_pilot" ){
			my $testunit = $tunit;
			print "Scanning TEST UNIT \'$testunit\' for .git directory\n";
			if( -e "$target_dir/$testunit/.git" ){
				print "TEST UNIT \'$testunit\' is already cloned from GIT\n";
			}else{
				print "Checking out Whether TEST UNIT \'$testunit\' exists in GIT\n";
				my $cmd = "git ls-remote git+ssh://test-server\@git.eucalyptus-systems.com/mnt/repos/qa/testunit/$testunit";
				print "\n";
				print $cmd . "\n";
				print "\n";
				my $git_check = `$cmd`;

				if( $git_check =~ /^(\S+)\s+HEAD/m ){
					print "-----------------------------------------------------------------------------------------\n";
					print "CONVERTING TEST-UNIT $testunit from BZR to GIT\n";
					print "\n";

					print "STEP 1. Deleting the Existing TEST-UNIT $testunit\n";
					print "rm -fr $target_dir/$testunit\n";
					system("rm -fr $target_dir/$testunit");
					print "\n";

					print "STEP 2. Clone TEST-UNIT $testunit from GIT\n";
					my $cmd2 = "git clone git+ssh://test-server\@git.eucalyptus-systems.com/mnt/repos/qa/testunit/$testunit";
					print "\n";
					print $cmd2 . "\n";
					system("cd $target_dir; $cmd2");
					print "\n";
					print "-----------------------------------------------------------------------------------------\n";
					print "\n";

				}else{
					$not_converted .= $testunit . " "; 
					print "[WARNING]\tTEST-UNIT $testunit doest not exist in GIT repo\n";
					print "\n";
				};
			};
			print "\n";
		};
	};

	close(CONF);

	print "\n";
	print "#####################################################################################\n";
	print "GIT CONVERSION COMPLETE\n";
	print "#####################################################################################\n";
	print "\n";

	if( $not_converted ne "" ){
		print "\n";
		print "[NOTICE]\tLIST OF TEST-UNITS THAT WERE NOT CONVERTED TO GIT\n";
		print "TEST-UNIT\t" . $not_converted . "\n";
		print "\n";
	};


	return 0;
};

1;

