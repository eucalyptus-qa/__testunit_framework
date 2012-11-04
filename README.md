
=== Eucalyptus Testunit Framework ===

Eucalyptus Testunit Framework is designed to run a list of test scripts written by Eucalyptus developers.



=== How to Set Up Testunit Environment ===

On Ubuntu Linux Distribution,

### UPDATE THE IMAGE
apt-get -y update

### BE SURE THAT THE CLOCK IS IN SYNC
apt-get -y install ntp
date

### INSTALL DEPENDENCIES -- YOUR TESTUNIT MIGHT NOT NEED ALL THE PACKAGES BELOW; CHECK THE TESTUNIT DESCRIPTION.
apt-get -y install git-core bzr gcc make ruby libopenssl-ruby curl rubygems swig help2man libssl-dev python-dev libright-aws-ruby nfs-common openjdk-6-jdk zip libdigest-hmac-perl libio-pty-perl libnet-ssh-perl euca2ools

### CLONE test_share DIRECTORY FOR TESTUNIT -- YOUR TESTUNIT MIGHT NOT NEED test_share DIRECTORY. CHECK THE TESTUNIT DESCRIPTION.
git clone git://github.com/eucalyptus-qa/test_share.git

### CREATE /home/test-server/test_share DIRECOTY AND LINK IT TO THE CLONED test_share
mkdir -p /home/test-server
ln -s ~/test_share/ /home/test-server/.

### CLONE TESTUNIT OF YOUR CHOICE
git clone git://github.com/eucalyptus-qa/<testunit_of_your_choice>

### CHANGE DIRECTORY
cd ./<testunit_of_your_choice>

### CREATE 2b_tested.lst FILE in ./input DIRECTORY
vim ./input/2b_tested.lst

### TEMPLATE OF 2b_tested.lst, SEPARATED BY TAB
<code>
192.168.51.85	CENTOS	6.3	64	BZR	[CC00 UI CLC SC00 WS]
192.168.51.86	CENTOS	6.3	64	BZR	[NC00]
</code>

### RUN THE TEST
./run_test.pl <testunit_of_your_choice>.conf



=== How to Example the Test Result ===

cd ./artifacts
ls -l



=== How to Rerun the Testunit ===

./cleanup_test.pl
./run_test.pl <testunit_of_your_choice>.conf

