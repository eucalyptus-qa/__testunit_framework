#!/usr/bin/perl

use strict;

my $test_unit = "";
my $conf_filename = "";

###	Checking Test Unit Name
my $this_dir = `pwd`;
chomp($this_dir);

my @temp_array = split("\/", $this_dir);

$test_unit = $temp_array[@temp_array-1];

if( $test_unit eq "" ){
	print "ERROR! CANNOT DETECT TEST UNIT NAME!! \n";
	exit(1);
};

$conf_filename = $test_unit . ".conf";

print "\n";
print "Test Unit Name: $test_unit\n";
print "Config File : $conf_filename\n";
print "\n";

if( !( -e "$this_dir/$conf_filename") ){
	print "ERROR! CANNOT FIND CONFIG FILE $conf_filename !!\n";
	exit(1);
};


###################################### VALIDATE CONF FILE ###################################

open(CONF, "< $conf_filename") or die $!;
my $line;

my $header = "";
my $body = "";
my $t_count = 0;
my $is_body = 0;

my @run_array;
my @precond_array;
my @postcond_array;
my @timeout_array;
my @sleep_array;
my @githash_array;

my $prerun_run = "";
my $prerun_precond = "";
my $prerun_postcond = "";
my $prerun_timeout = 0;
my $prerun_sleep = 0;
my $prerun_githash = "";

my $postrun_run = "";
my $postrun_precond = "";
my $postrun_postcond = "";
my $postrun_timeout = 0;
my $postrun_sleep = 0;
my $postrun_githash = "";

my $fallback_run = "";
my $fallback_precond = "";
my $fallback_postcond = "";
my $fallback_timeout = 0;
my $fallback_sleep = 0;
my $fallback_githash = "";

my $is_prerun = 0;
my $is_postrun = 0;
my $is_fallback = 0;

my $count = 0;
my $test = "NONE";
my $precond = "";
my $postcond = "";
my $timeout = 0;
my $sleep = 0;
my $githash = "";

while($line=<CONF>){
	chomp($line);
	$line =~ s/\r//g;
	
	if( $is_body == 0 ){

		### HEADER
		if( $line =~ /^PRERUN/ || $line =~ /^STAGE(\d+)/ ){
			$is_body = 1;
		}elsif( $line =~ /^TEST_NAME\s+(\S+)/ ){
			if( $1 ne $test_unit ){
				print "\n";
				print "ERROR! in Line:\n";
				print "\n";
				print "$line\n";
				print "\n";
				print "TEST_NAME must be \'$test_unit\' !!\n";
				print "\n";

				exit(1);
			};
			$header .= $line . "\n";
		}elsif( $line =~ /^TOTAL_STAGES\s+(\d+)/ ){
			$t_count = $1;
			$header .= $line . "\n";
		}else{
			$header .= $line . "\n";
		};
	};

	if( $is_body == 1 ){

		if( $line =~/^PRERUN/ ){
			$is_prerun = 1;		
		}elsif( $line =~/^POSTRUN/ ){
			$is_postrun = 1;		
		}elsif( $line =~/^FALLBACK/ ){
			$is_fallback = 1;
			$is_postrun = 0;
		}elsif( $line =~ /^STAGE(\d+)/ ){
			$is_prerun = 0;
			$is_postrun = 0;
			$is_fallback = 0;
			$test = "NONE";
			$precond = "";
			$postcond = "";
			$timeout = 0;
			$sleep = 0;
			$githash = "";
		};

		if( $is_prerun ){
			if( $line =~ /^\s+RUN\s+(.+)/ ){
				$prerun_run = $1;
			}elsif( $line =~ /^\s+_PRE_COND\s+(.+)/ ){
				$prerun_precond = $1;			
			}elsif( $line =~ /^\s+_POST_COND\s+(.+)/ ){
				$prerun_postcond = $1;			
			}elsif( $line =~ /^\s+TIMEOUT\s+(\d+)/ ){
				$prerun_timeout = $1;			
			}elsif( $line =~ /^\s+SLEEP\s+(\d+)/ ){
				$prerun_sleep = $1;
			}elsif( $line =~ /^\s+GITHASH\s+(\S+)/ ){
				$prerun_githash = $1;
			};		
		}elsif( $is_postrun ){
			if( $line =~ /^\s+RUN\s+(.+)/ ){
				$postrun_run = $1;
			}elsif( $line =~ /^\s+_PRE_COND\s+(.+)/ ){
				$postrun_precond = $1;			
			}elsif( $line =~ /^\s+_POST_COND\s+(.+)/ ){
				$postrun_postcond = $1;	
			}elsif( $line =~ /^\s+TIMEOUT\s+(\d+)/ ){
				$postrun_timeout = $1;			
			}elsif( $line =~ /^\s+SLEEP\s+(\d+)/ ){
				$postrun_sleep = $1;
			}elsif( $line =~ /^\s+GITHASH\s+(\S+)/ ){
				$postrun_githash = $1;
			};
		}elsif( $is_fallback ){
			if( $line =~ /^\s+RUN\s+(.+)/ ){
				$fallback_run = $1;
			}elsif( $line =~ /^\s+_PRE_COND\s+(.+)/ ){
				$fallback_precond = $1;			
			}elsif( $line =~ /^\s+_POST_COND\s+(.+)/ ){
				$fallback_postcond = $1;	
			}elsif( $line =~ /^\s+TIMEOUT\s+(\d+)/ ){
				$fallback_timeout = $1;			
			}elsif( $line =~ /^\s+SLEEP\s+(\d+)/ ){
				$fallback_sleep = $1;
			}elsif( $line =~ /^\s+GITHASH\s+(\S+)/ ){
				$fallback_githash = $1;
			};		
		}else{
			if( $line =~ /^\s+RUN\s+(.+)/ ){
				$test = $1;
			}elsif( $line =~ /^\s+_PRE_COND\s+(.+)/ ){
				$precond = $1;			
			}elsif( $line =~ /^\s+_POST_COND\s+(.+)/ ){
				$postcond = $1;
			}elsif( $line =~ /^\s+TIMEOUT\s+(\d+)/ ){
				$timeout = $1;
			}elsif( $line =~ /^\s+SLEEP\s+(\d+)/ ){
				$sleep = $1;
			}elsif( $line =~ /^\s+GITHASH\s+(\S+)/ ){
				$githash = $1;
			}elsif( $line =~ /^END/ ){
				push(@run_array, $test);
				push(@precond_array, $precond);
				push(@postcond_array, $postcond);
				push(@timeout_array, $timeout);
				push(@sleep_array, $sleep);
				push(@githash_array, $githash);
			};

		};

	};


};
close(CONF);

print "\n";

my $real_t_count = @run_array;

if( $t_count != $real_t_count ){
	print "WARNING! \'TOTAL_STAGES $t_count\' is incorrect !!\n";
	print "Actual Number of Stages is $real_t_count\n";
	print "\n";
	print "Adjusting to\n";
	print "TOTAL_STAGES\t" . $real_t_count . "\n";
	print "\n";
	$header =~ s/TOTAL_STAGES\s+(\d+)/TOTAL_STAGES\t$real_t_count/g;
	print "\n";

};

print "\n";
print "-------------------------------------";
print " NEW auto_pilot.conf ";
print "-------------------------------------\n";
print "\n";
print "$header\n";

$body = "";

if( $prerun_run ne "" ){
	$body .= "PRERUN\n";
	if( $prerun_precond ne "" ){
		$body .= "\t_PRE_COND " . $prerun_precond . "\n";
	};
	$body .= "\tRUN " . $prerun_run . "\n";
	if( $prerun_githash ne "" ){
		$body .= "\tGITHASH " . $prerun_githash . "\n";
	};
	$body .= "\tTIMEOUT " . $prerun_timeout . "\n";
	$body .= "\tSLEEP " . $prerun_sleep . "\n";
	if( $prerun_postcond ne "" ){
		$body .= "\t_POST_COND " . $prerun_postcond . "\n";
	};
	$body .= "END\n\n";
};

for(my $i; $i<@run_array; $i++){

	$test = $run_array[$i];
	$precond = $precond_array[$i];
	$postcond = $postcond_array[$i];
	$timeout = $timeout_array[$i];
	$sleep = $sleep_array[$i];
	$githash = $githash_array[$i];

	my $stage = sprintf("%02d", $i+1);
	$body .= "STAGE" . $stage . "\n";
	if( $precond ne "" ){
		$body .= "\t_PRE_COND " . $precond . "\n";
	};
	$body .= "\tRUN " . $test . "\n";
	if( $githash ne "" ){
		$body .= "\tGITHASH " . $githash . "\n";
	};
	$body .= "\tTIMEOUT " . $timeout . "\n";
	$body .= "\tSLEEP " . $sleep . "\n";
	if( $postcond ne "" ){
		$body .= "\t_POST_COND " . $postcond . "\n";
	};
	$body .= "END\n\n";

};


if( $postrun_run ne "" ){
	$body .= "POSTRUN\n";
	if( $postrun_precond ne "" ){
		$body .= "\t_PRE_COND " . $postrun_precond . "\n";
	};
	$body .= "\tRUN " . $postrun_run . "\n";
	if( $postrun_githash ne "" ){
		$body .= "\tGITHASH " . $postrun_githash . "\n";
	};
	$body .= "\tTIMEOUT " . $postrun_timeout . "\n";
	$body .= "\tSLEEP " . $postrun_sleep . "\n";
	if( $postrun_postcond ne "" ){
		$body .= "\t_POST_COND " . $postrun_postcond . "\n";
	};
	$body .= "END\n\n";
};


if( $fallback_run ne "" ){
	$body .= "FALLBACK\n";
	if( $fallback_precond ne "" ){
		$body .= "\t_PRE_COND " . $fallback_precond . "\n";
	};
	$body .= "\tRUN " . $postrun_run . "\n";
	if( $fallback_githash ne "" ){
		$body .= "\tGITHASH " . $fallback_githash . "\n";
	};
	$body .= "\tTIMEOUT " . $postrun_timeout . "\n";
	$body .= "\tSLEEP " . $postrun_sleep . "\n";
	if( $fallback_postcond ne "" ){
		$body .= "\t_POST_COND " . $fallback_postcond . "\n";
	};
	$body .= "END\n\n";
};

print "$body";


print "-------------------------------------";
print " END of NEW auto_pilot.conf ";
print "-------------------------------------\n";
print "\n";
print "\n";
print "\n";

print "Moving the Existing Config File \'$conf_filename\' to \'" . $conf_filename . ".old\'\n";
print "mv -f ./$conf_filename ./". $conf_filename .".old\n"; 
system("mv -f ./$conf_filename ./". $conf_filename .".old"); 
print "\n";
print "\n";

print "Creating New Config File \'$conf_filename\'\n";

open(NEWCONF, "> $conf_filename") or die $!;
print NEWCONF $header;
print NEWCONF $body;
close(NEWCONF); 

print "..DONE\n";

print "\n";
print "\n";

exit(0);


############################### SUBROUTINES #################################

1;

