#!/usr/bin/perl

# While this script is running, it will print out the state of each alarm on the system.
# This script is an example of calling external scripts in reaction to a
# monitor changing state.  Simply replace the print() commands with system(),
# for example, to call external scripts.

use strict;
use warnings;
use ZoneMinder;
use Switch;

$| = 1;
my $Camera_1 = 0;
my $Camera_2 = 0;

my @monitors;
my $cmd = '';
my $dbh = zmDbConnect();

my $sql = "SELECT * FROM Monitors
  WHERE find_in_set( Function, 'Modect,Mocord,Nodect' )".
  ( $Config{ZM_SERVER_ID} ? 'AND ServerId=?' : '' )
  ;

my $sth = $dbh->prepare_cached( $sql )
  or die( "Can't prepare '$sql': ".$dbh->errstr() );

my $res = $sth->execute()
  or die( "Can't execute '$sql': ".$sth->errstr() );

while ( my $monitor = $sth->fetchrow_hashref() ) {
    push( @monitors, $monitor );
}

while (1) {
        foreach my $monitor (@monitors) {
               # Check shared memory ok
               if ( !zmMemVerify( $monitor ) ) {
                 zmMemInvalidate( $monitor );
                 next;
                }

                my $monitorState = zmGetMonitorState($monitor);
                printState($monitor->{Id}, $monitor->{Name}, $monitorState);
        }
        sleep 1;
}

sub printState {
        my ($monitor_id, $monitor_name, $state) = @_;
        my $time = localtime();


        switch ($state) {
                case 0 {
						
			if($monitor_name eq 'Camera-1'){
				$Camera_1 = 0;
			}
			if($monitor_name eq 'Camera-2'){
				$Camera_2 = 0;
			}
		}
                case 1 { 
			
		}
		case 2 {
						
			if($monitor_name eq 'Camera-1'){
				if ($Camera_1 eq 0){
					system("sudo /etc/zm/zm-telegram.sh $monitor_name");
					system("sudo /etc/zm/camera-1.sh");
				}
			}
			if($monitor_name eq 'Camera-2'){
                                if ($Camera_2 eq 0){
                                        system("sudo /etc/zm/zm-telegram.sh $monitor_name");
					system("sudo /etc/zm/camera-2.sh");
                                }
                        }
			if($monitor_name eq 'Camera-1'){
				$Camera_1 = 1;
			}
			if($monitor_name eq 'Camera-2'){
				$Camera_2 = 1;
			}
		case 3 { 
			 
		}
        }
}
}
