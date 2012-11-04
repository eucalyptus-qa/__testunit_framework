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

validate_auto_pilot();

my @test_list;

read_auto_pilot_conf(\@test_list, $seq_dir);

foreach my $t (@test_list){

	my $index = $t->{'INDEX'};
	my $stage = $t->{'STAGE'};
	my $gitrepo = $t->{'GITREPO'};
	my $githash = $t->{'GITHASH'};

	print "\n";
	print "INDEX\t$index\n";
	print "STAGE\t$stage\n";
	print "GITREPO\t$gitrepo\n";
	print "GITHASH\t$githash\n";
};


populate_sequence(\@test_list, $seq_dir);


exit(0);


############################### SUBROUTINES #################################

sub validate_auto_pilot{

	print "\n";
	print "Running Validate_Conf_File Script\n";
	print("perl ./validate_conf_file.pl\n");
	system("perl ./validate_conf_file.pl");

	return 0;
};


sub read_auto_pilot_conf{

	my $target_dir = $_[1];
	my $conf_file = $target_dir . "/auto_pilot/auto_pilot.conf";

	print "\n";
	print "#####################################################################################\n";
	print "Scanning Sequence Directory $conf_file\n";
	print "#####################################################################################\n";
	print "\n";


	open( LIST, "< $conf_file" ) or die "$! : CANNOT OPEN $conf_file !!\n";

	my $index = 0;
	my $stage = "";
	my $testunit = "";
	my $githash = "LATEST";
	my $line;

	while($line=<LIST>){
		chomp($line);
		$line =~ s/\r//g;

		if($line =~ /^PRERUN/){
			$stage = "PRERUN";
			$testunit = "";
			$githash = "LATEST";
		}elsif($line =~ /^POSTRUN/){		
			$stage = "POSTRUN";
			$testunit = "";
			$githash = "LATEST";	
		}elsif($line =~ /^FALLBACK/){		
			$stage = "FALLBACK";
			$testunit = "";
			$githash = "LATEST";	
		}elsif($line =~ /^STAGE(\d+)/){
			$stage = $1;
			$testunit = "";
			$githash = "LATEST";	
		}elsif( $line =~ /^\s+RUN TEST\s+(.+)/ ){
			$testunit = $1;
			my @temp_array = split(" ", $testunit);
			$testunit = $temp_array[0];
			print "Scanning TESTUNIT \'$testunit\'\n";
		}elsif( $line =~ /^\s+GITHASH\s+(\S+)/ ){
			$githash = $1;
		}elsif( $line =~ /^END/ ){
			my $h = {};
			$h->{'INDEX'} = $index;
			$h->{'STAGE'} = $stage;
			$h->{'GITREPO'} = $testunit;
			$h->{'GITHASH'} = $githash;
			
			${$_[0]}[$index] = $h;

			$index++;
			$testunit = "";
			$githash = "LATEST";
		};

	};

	close(LIST);

	return 0;
};



sub populate_sequence{
	
	my $target_dir = $_[1];
        my $conf_file = $target_dir . "/auto_pilot/auto_pilot.conf";

	print "\n";
	print "#####################################################################################\n";
	print "Populating Sequence Directory $target_dir\n";
	print "#####################################################################################\n";
	print "\n";
	print "\n";

	my $git_repo_prefix = "git+ssh://test-server\@git.eucalyptus-systems.com/mnt/repos/qa/testunit";

	my $tempbuf = `cat $conf_file | grep GIT_REPO_PREFIX`;
	if( $tempbuf =~ /^GIT_REPO_PREFIX\s+(\S+)/m ){
		$git_repo_prefix = $1;
		print "Detected Custom GIT_REPO_PREFIX: $git_repo_prefix\n";
	}else{
		print "Default GIT_REPO_PREFIX: $git_repo_prefix\n";
	};
	
	print "\n";

	my @items = @{$_[0]};

	foreach my $item (@items){
		my $gitrepo = $item->{'GITREPO'};
		my $githash = $item->{'GITHASH'};
		my $testunit = $gitrepo;
		if( $gitrepo =~ /^git/ ){
			my @temp_array = split("/", $testunit);
			my $size =  @temp_array;
			$testunit = $temp_array[$size-1];
		};
		print "Preparing TESTUNIT \'$gitrepo\'\n";

		if( -e "$target_dir/$testunit" ){
			print "TESTUNIT \'$testunit\' Already Exists\n";
		}else{
			my $cmd;
			if( $gitrepo =~ /^git/ ){
				print "REMOTE GIT Checkout: \'$gitrepo\'\n";
				$cmd = "git clone $gitrepo";
			}else{
				print "LOCAL GIT Checkout: \'$testunit\'\n";
				$cmd = "git clone " . $git_repo_prefix . "/". $testunit;
			};
			print $cmd . "\n";
			system("cd $target_dir; $cmd");

			if( $githash ne "" && $githash ne "LATEST" ){
				$cmd = "git reset --hard $githash";
				print $cmd . "\n";
				system("cd $target_dir/$testunit; $cmd");
			};
		};
		print "\n";
	};


	print "\n";
	print "#####################################################################################\n";
	print "SEQUENCE POPULATED\n";
	print "#####################################################################################\n";
	print "\n";


	return 0;
};

1;

